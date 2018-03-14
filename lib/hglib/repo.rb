# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'hglib' unless defined?( Hglib )


class Hglib::Repo
	extend Loggability

	# Loggability API -- log to the hglib logger
	log_to :hglib


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
	### the file.
	def status( *args, **options )
		response = self.server.run( :status, *args, **options )
		self.log.debug "Parsing status response: %p" % [ response ]

		return response.each_slice( 2 ).inject({}) do |hash, (raw_status, path)|
			path = Pathname( path.chomp )
			hash[ path ] = raw_status.strip
			hash
		end
	end


	### Return an Array of Hglib::Repo::LogEntry objects that describes the revision
	### history of the specified +files+ or the entire project.
	def log( *files, **options )
		rawlog = self.server.run( :log, *files, **options )
		self.log.debug "Parsing log response: %p" % [ rawlog ]

		return rawlog #.map {|entry| Hglib::Repo::LogEntry.parse(entry) }
	end


	#########
	protected
	#########

	### Create an Hglib::Server for this Repo.
	def create_server
		return Hglib::Server.new( self.path.to_s )
	end

end # class Hglib::Repo
