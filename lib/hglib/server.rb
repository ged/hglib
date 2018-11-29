# -*- ruby -*-
# frozen_string_literal: true

require 'shellwords'
require 'loggability'
require 'hglib' unless defined?( Hglib )


# A mercurial server object. This uses the Mercurial Command Server protocol to
# execute Mercurial commands.
#
# Refs:
# - https://www.mercurial-scm.org/wiki/CommandServer
#
class Hglib::Server
	extend Loggability


	# String#unpack template for message headers from the command server
	HEADER_TEMPLATE = 'aI>'

	# Array#pack template for commands sent to the command server
	COMMAND_TEMPLATE = 'A*I>A*'

	# Array#pack template for plain messages sent to the command server
	MESSAGE_TEMPLATE = 'I>A*'


	# Loggability API -- send logs to the logger in the top-level module
	log_to :hglib


	### Turn the specified +opthash+ into an Array of command line options.
	def self::mangle_options( **options )
		return options.flat_map do |name, val|
			prefix = name.length > 1 ? '--' : '-'
			optname = "%s%s" % [ prefix, name.to_s.gsub(/_/, '-') ]

			case val
			when TrueClass
				[ optname ]
			when FalseClass, NilClass
				[ optname.sub(/\A--/, '--no-') ] if optname.start_with?( '--' )
			when String
				if optname.start_with?( '--' )
					[ "#{optname}=#{val}" ]
				else
					[ optname, val ]
				end
			else
				raise ArgumentError, "can't handle command option: %p" % [{ name => val }]
			end
		end.compact
	end


	### Create a new Hglib::Server that will be invoked for the specified +repo+.
	### Any additional +args+ given will be passed to the `hg serve` command
	### on startup.
	def initialize( repo=nil, **args )
		@repo = Pathname( repo ) if repo

		@reader = nil
		@writer = nil

		@pid = nil

		@byte_input_callback = nil
		@line_input_callback = nil
	end


	######
	public
	######

	##
	# The Pathname to the repository the server should target
	attr_reader :repo

	##
	# The additional arguments to send to the command server on startup
	attr_reader :args

	##
	# The reader end of the pipe used to communicate with the command server.
	attr_accessor :reader

	##
	# The writer end of the pipe used to communicate with the command server.
	attr_accessor :writer

	##
	# The PID of the running command server if there is one
	attr_accessor :pid

	##
	# The callable used to fetch byte-oriented input
	attr_accessor :byte_input_callback
	protected :byte_input_callback=

	##
	# The callable used to fetch line-oriented input
	attr_accessor :line_input_callback
	protected :line_input_callback=


	### Register a +callback+ that will be called when the command server asks for
	### byte-oriented input. The callback will be called with the (maximum) number
	### of bytes to return.
	def on_byte_input( &callback )
		raise LocalJumpError, "no block given" unless callback
		self.byte_input_callback = callback
	end


	### Register a +callback+ that will be called when the command server asks for
	### line-oriented input. The callback will be called with the (maximum) number
	### of bytes to return.
	def on_line_input( &callback )
		raise LocalJumpError, "no block given" unless callback
		self.line_input_callback = callback
	end


	### Register the callbacks necessary to read both line and byte input from the
	### specified +io+, which is expected to respond to #gets and #read.
	def register_input_callbacks( io=$stdin )
		self.on_byte_input( &io.method(:read) )
		self.on_line_input( &io.method(:gets) )
	end


	### Run the specified +command+ with the given +args+ via the server and return
	### the result. If the command requires +input+, the callbacks registered with
	### #on_byte_input and #on_line_input will be used to read it. If one of these
	### callbacks is not registered, an IOError will be raised.
	def run( command, *args, **options )
		self.log.debug "Running command: %p" % [ Shellwords.join([command.to_s] + args) ]
		self.start unless self.started?

		done = false
		output = []

		args.compact!
		args += self.class.mangle_options( options )

		self.write_command( 'runcommand', command, *args )

		until done
			channel, data = self.read_message

			case channel
			when 'o'
				# self.log.debug "Got command output: %p" % [ data ]
				output << data
			when 'r'
				done = true
			when 'e'
				self.log.error "Got command error: %p" % [ data ]
				raise Hglib::CommandError, data
			when 'L'
				self.log.debug "Server requested line input (%d bytes)" % [ data ]
				input = self.get_line_input( data.to_i )
				self.write_message( input.chomp + "\n" )
			when 'I'
				self.log.debug "Server requested byte input (%d bytes)" % [ data ]
				input = self.get_byte_input( data.to_i )
				self.write_message( input )
			else
				msg = "Unexpected channel %p" % [ channel ]
				self.log.error( msg )
				raise( msg ) if channel =~ /\p{Upper}/ # Mandatory
			end
		end

		return output
	end


	### Returns +true+ if the underlying command server has been started.
	def is_started?
		return self.pid ? true : false
	end
	alias_method :started?, :is_started?


	### Open a pipe and start the command server.
	def start
		self.log.debug "Starting."
		self.spawn_server
		self.read_hello
	end


	### Stop the command server and clean up the pipes.
	def stop
		return unless self.started?

		self.log.debug "Stopping."
		self.writer.close if self.writer
		self.writer = nil
		self.reader.close if self.reader
		self.reader = nil
		self.stop_server
	end


	#########
	protected
	#########

	### Call the #on_line_input callback to read at most +max_bytes+. Raises an
	### IOError if no callback is registered.
	def get_line_input( max_bytes )
		callback = self.line_input_callback or
			raise IOError, "cannot read input: no line input callback registered"

		return callback.call( max_bytes )
	end


	### Call the #on_byte_input callback to read at most +max_bytes+. Raises an
	### IOError if no callback is registered.
	def get_byte_input( max_bytes )
		callback = self.byte_input_callback or
			raise IOError, "cannot read input: no byte input callback registered"

		return callback.call( max_bytes )
	end


	### Fork a child and run Mercurial in command-server mode.
	def spawn_server
		self.reader, child_writer = IO.pipe
		child_reader, self.writer = IO.pipe

		cmd = self.server_start_command
		self.pid = Process.spawn( *cmd, out: child_writer, in: child_reader, close_others: true )
		self.log.debug "Spawned command server at PID %d" % [ self.pid ]

		child_writer.close
		child_reader.close
	end


	### Kill the command server if it's running
	def stop_server
		if self.pid
			self.log.debug "Stopping command server at PID %d" % [ self.pid ]
			Process.kill( :TERM, self.pid )
			Process.wait( self.pid, Process::WNOHANG )
			self.pid = nil
		end
	end


	### Write the specified message to the command server. Raises an exception if
	### the server is not yet started.
	def write_command( command, *args )
		data = args.map( &:to_s ).join( "\0" )
		message = [ command + "\n", data.bytesize, data ].pack( COMMAND_TEMPLATE )
		self.log.debug "Writing command %p to command server." % [ message ]
		self.writer.write( message )
	end


	### Write the specified +message+ to the command server.
	def write_message( data )
		message = [ data.bytesize, data ].pack( MESSAGE_TEMPLATE )
		self.log.debug "Writing message %p to command server." % [ message ]
		self.writer.write( message )
	end


	### Read the cmdserver's banner.
	def read_hello
		_, message = self.read_message
		self.log.debug "Hello message:\n%s" % [ message ]
	end


	### Read a single channel identifier and message from the command server. Raises
	### an exception if the server is not yet started.
	def read_message
		raise "Server is not yet started" unless self.started?
		header = self.reader.read( 5 ) or raise "Server aborted."
		channel, bytes = header.unpack( HEADER_TEMPLATE )
		self.log.debug "Read channel %p message (%d bytes)" % [ channel, bytes ]

		# Input requested; return the requested length as the message
		if channel == 'I' || channel == 'L'
			return channel, bytes
		end

		self.log.debug "Reading %d more bytes of the message" % [ bytes ]
		message = self.reader.read( bytes ) unless bytes.zero?
		self.log.debug "  read message: %p" % [ message ]
		return channel, message
	end


	### Return the command-line command for starting the command server.
	def server_start_command
		cmd = [
			Hglib.hg_path.to_s,
			'--config',
			'ui.interactive=True',
			'serve',
			'--cmdserver',
			'pipe',
		]

		cmd << '--repository' << self.repo.to_s if self.repo

		return cmd
	end


end # class Hglib::Server
