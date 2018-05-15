# -*- ruby -*-
# frozen_string_literal: true

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
		Loggability[ self ].debug "Parsing status response: %p" % [ response ]

		return {} if response.length == 1 && response.first.empty?
		return response.each_slice( 2 ).inject({}) do |hash, (raw_status, path)|
			path = Pathname( path.chomp )
			hash[ path ] = raw_status.strip
			hash
		end
	end


	### Return a Hglib::Repo::Id that identifies the repository state at the
	### specified +revision+, or the current revision if unspecified. A +revision+
	### of `.` identifies the working directory parent without uncommitted changes.
	def id( revision=nil )
		options = {}
		options[:rev] = revision if revision

		response = self.server.run( :id, **options )
		Loggability[ self ].debug "Got ID response: %p" % [ response ]

		return Hglib::Repo::Id.parse( response.first )
	end


	### Return an Array of Hglib::Repo::LogEntry objects that describes the revision
	### history of the specified +files+ or the entire project.
	def log( *files, **options )
		rawlog = self.server.run( :log, *files, **options )
		return rawlog.map {|entry| Hglib::Repo::LogEntry.parse(entry) }
	end


	#########
	protected
	#########

	### Create an Hglib::Server for this Repo.
	def create_server
		return Hglib::Server.new( self.path.to_s )
	end

end # class Hglib::Repo
