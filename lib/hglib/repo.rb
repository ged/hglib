# -*- ruby -*-
# frozen_string_literal: true

require 'json'
require 'loggability'
require 'hglib' unless defined?( Hglib )


class Hglib::Repo
	extend Loggability

	# Loggability API -- log to the hglib logger
	log_to :hglib


	autoload :Id, 'hglib/repo/id'
	autoload :LogEntry, 'hglib/repo/log_entry'


	### Create a new Repo object that will operate on the Mercurial repo at the
	### specified +path+.
	def initialize( path )
		@path = Pathname( path )
		@server = nil
	end


	######
	public
	######

	##
	# The path to the repository
	attr_reader :path


	### Return the Hglib::Server started for this Repo, creating it if necessary.
	def server
		return @server ||= self.create_server
	end


	### Return a Hash of the status of the files in the repo, keyed by Pathname of
	### the file. An empty Hash is returned if there are no files with one of the
	### requested statuses.
	def status( *args, **options )
		response = self.server.run( :status, *args, **options )
		self.logger.debug "Parsing status response: %p" % [ response ]

		return {} if response.length == 1 && response.first.empty?
		return response.each_slice( 2 ).inject({}) do |hash, (raw_status, path)|
			path = Pathname( path.chomp )
			hash[ path ] = raw_status.strip
			hash
		end
	end
	alias_method :stat, :status


	### Return a Hglib::Repo::Id that identifies the repository state at the
	### specified +revision+, or the current revision if unspecified. A +revision+
	### of `.` identifies the working directory parent without uncommitted changes.
	def id( revision=nil )
		options = {}
		options[:rev] = revision if revision

		response = self.server.run( :id, **options )
		self.logger.debug "Got ID response: %p" % [ response ]

		return Hglib::Repo::Id.parse( response.first )
	end


	### Return an Array of Hglib::Repo::LogEntry objects that describes the revision
	### history of the specified +files+ or the entire project.
	def log( *files, **options )
		options[:graph] = false
		options[:T] = 'json'

		jsonlog = self.server.run( :log, *files, **options )
		entries = JSON.parse( jsonlog.join )

		return entries.map {|entry| Hglib::Repo::LogEntry.new(entry) }
	end


	### Commit the specified +files+ with the given +options+.
	def commit( *files, **options )
		response = self.server.run( :commit, *files, **options )
		self.logger.debug "Got COMMIT response: %p" % [ response ]

		return true
	end


	### Pull changes from the specified +source+ (which defaults to the +default+
	### path) into the local repository.
	def pull( source=nil, **options )
		response = self.server.run( :pull, source, **options )
		self.logger.debug "Got PULL response: %p" % [ response ]

		return true
	end


	### Pull changes from the specified +source+ into the local repository and update
	### to the new branch head if new descendents were pulled.
	def pull_update( source=nil, **options )
		options[:update] = true
		return self.pull( source, **options )
	end


	#########
	protected
	#########

	### Create an Hglib::Server for this Repo.
	def create_server
		return Hglib::Server.new( self.path.to_s )
	end


	### Return the logger for this object; aliased to avoid the conflict with `hg log`.
	def logger
		return Loggability[ self ]
	end

end # class Hglib::Repo
