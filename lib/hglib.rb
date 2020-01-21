# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'pathname'


# Toplevel namespace
module Hglib
	extend Loggability


	# Package version
	VERSION = '0.8.0'

	# Version control revision
	REVISION = %q$Revision$

	# The default path to the `hg` command
	DEFAULT_HG_PATH = begin
		paths = ENV['PATH'].
			split( File::PATH_SEPARATOR ).
			map {|dir| Pathname(dir) + 'hg' }

		paths.find( &:executable? ) || Pathname( '/usr/bin/hg' )
	end


	# Base exception class for errors raised by this library
	class Error < RuntimeError; end


	# Specialized exception for handling errors returned by the command server.
	class CommandError < Hglib::Error

		### Create a new CommandError with the given +args+.
		def initialize( command, *messages, details: nil )
			@command = command
			@messages = messages.flatten.map( &:chomp )
			@messages << "error in hg command" if @messages.empty?
			@details = details
		end


		##
		# The command that resulted in an error
		attr_reader :command

		##
		# The Array of error messages generated by the command
		attr_reader :messages

		##
		# Additional details of the error
		attr_reader :details


		### Returns +true+ if the command resulted in more than one error message.
		def multiple?
			return self.messages.length > 1
		end


		### Overridden to format multi-message errors in a more-readable way.
		def message
			msg = String.new( encoding: 'utf-8' )

			msg << "`%s`:" % [ self.command ]

			if self.multiple?
				self.messages.each do |errmsg|
					msg << "\n" << '  - ' << errmsg
				end
				msg << "\n"
			else
				msg << ' ' << self.messages.first
			end

			msg << "\n" << self.details if self.details

			return msg
		end

	end # class CommandError


	# Exception raised when a command failed because the extension it belongs to was
	# disabled.
	class DisabledExtensionError < Hglib::Error

		### Create a new instance for the given +command+ and the name of the
		### +extension+ which defines it.
		def initialize( command, extension )
			@command = command
			@extension = extension
		end


		##
		# The command that failed
		attr_reader :command

		##
		# The name of the extension which defines the #command
		attr_reader :extension


		### Return an message describing what the command and disabled extension were.
		def message
			return "`%s`: command is provided by disabled extension `%s`" % [
				self.command,
				self.extension,
			]
		end

	end # class DisabledError


	# Loggability API -- set up a Logger for Hglib objects
	log_as :hglib


	### Return the currently-configured path to the `hg` binary./
	def self::hg_path
		return @hg_path ||= DEFAULT_HG_PATH
	end


	### Set the path to the `hg` binary that will be used for any new commands.
	def self::hg_path=( new_path )
		@hg_path = Pathname( new_path )
	end


	# Set up automatic loading of submodules
	autoload :Config, 'hglib/config'
	autoload :Server, 'hglib/server'
	autoload :Repo, 'hglib/repo'
	autoload :Extension, 'hglib/extension'
	autoload :VersionInfo, 'hglib/version_info'


	### Return an Hglib::Server started with no repository.
	def self::server
		return @hg_server ||= Hglib::Server.new( nil )
	end


	### Shut down and remove the ::server if one exists. Mostly used for testing.
	def self::reset_server
		if ( server = @hg_server )
			@hg_server = nil
			server.stop
		end
	end


	### Returns +true+ if the specified +dir+ looks like it is a Mercurial
	### repository.
	def self::is_repo?( dir )
		dir = Pathname( dir )
		hgdir = dir + '.hg'
		return dir.directory? && hgdir.directory?
	end


	### Return an Hglib::Repo object for the specified +path+.
	def self::repo( path='.' )
		return Hglib::Repo.new( path )
	end


	### Clone the +source_repo+ to the specified +local_dir+, which defaults to a
	### directory with the basename of the +source_repo+ in the current working
	### directory.
	def self::clone( source_repo, local_dir=nil, **options )
		output = self.server.run( :clone, source_repo, local_dir, **options )
		self.log.debug "Clone output: %s" % [ output ]

		local_dir ||= Pathname.pwd + File.basename( source_repo )
		return self.repo( local_dir )
	end


	### Initialize a repository in the given +dir+ and return a Hglib::Repo
	### for it.
	def self::init( dir, **options )
		output = self.server.run( :init, dir, **options )
		self.log.debug "Init output: %s" % [ output ]

		return self.repo( dir )
	end


	extend Hglib::VersionInfo
	Hglib::Extension.load_all

end # module Hglib

