# -*- ruby -*-
# frozen_string_literal: true

require 'json'
require 'loggability'
require 'hglib' unless defined?( Hglib )


class Hglib::Repo
	extend Loggability

	# Loggability API -- log to the hglib logger
	log_to :hglib


	autoload :Bookmark, 'hglib/repo/bookmark'
	autoload :Id, 'hglib/repo/id'
	autoload :LogEntry, 'hglib/repo/log_entry'
	autoload :StatusEntry, 'hglib/repo/status_entry'
	autoload :Tag, 'hglib/repo/tag'


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
		response = self.server.run_with_json_template( :status, *args, **options )
		self.logger.debug "Parsing status response: %p" % [ response ]

		return response.map {|entry| Hglib::Repo::StatusEntry.new(entry) }
	end
	alias_method :stat, :status


	### Return a Hglib::Repo::Id that identifies the repository state at the
	### specified +revision+, or the current revision if unspecified. A +revision+
	### of `.` identifies the working directory parent without uncommitted changes.
	def identify( source=nil, **options )
		response = self.server.run_with_json_template( :identify, source, **options )
		self.logger.debug "Got ID response: %p" % [ response ]

		data = response.first
		return Hglib::Repo::Id.new( **data )
	end
	alias_method :identity, :identify
	alias_method :id, :identity


	### Return an Array of Hglib::Repo::LogEntry objects that describes the revision
	### history of the specified +files+ or the entire project.
	def log( *files, **options )
		options[:graph] = false

		entries = self.server.run_with_json_template( :log, *files, **options )
		self.logger.debug "Got log response: %p" % [ entries ]

		return entries.map {|entry| Hglib::Repo::LogEntry.new(entry) }
	end


	### Return a String showing differences between revisions for the specified
	### +files+ in the unified diff format.
	def diff( *files, **options )
		response = self.server.run( :diff, *files, **options )
		self.logger.debug "Got diff response: %p" % [ truncate(response) ]
		return response
	end


	### Schedule the given +files+ to be version controlled and added to the
	### repository on the next commit. To undo an add before that, see #forget.
	###
	### If no +files+ are given, add all files to the repository (except files
	### matching ".hgignore").
	###
	### Returns <code>true</code> if all files are successfully added.
	def add( *files, **options )
		response = self.server.run( :add, *files, **options )
		self.logger.debug "Got ADD response: %p" % [ response ]

		return true
	end


	### Add all new files and remove all missing files from the repository.
	###
	### Unless +files+ are given, new files are ignored if they match any of the
	### patterns in ".hgignore". As with #add, these changes take effect at the
	### next commit.
	###
	### Use the :similarity option to detect renamed files. This option takes a
	### percentage between 0 (disabled) and 100 (files must be identical) as its
	### value. With a value greater than 0, this compares every removed file with
	### every added file and records those similar enough as renames. Detecting
	### renamed files this way can be expensive. After using this option, you can
	### call #status with the <code>:copies</code> options to check which files
	### were identified as moved or renamed. If not specified, :similarity defaults
	### to 100 and only renames of identical files are detected.
	###
	### Returns <code>true</code> if all files are successfully added.
	def addremove( *files, **options )
		response = self.server.run( :addremove, *files, **options )
		self.logger.debug "Got ADD response: %p" % [ response ]

		return true
	end
	alias_method :add_remove, :addremove
	alias_method :addr, :addremove


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


	### Update the working directory or switch revisions.
	def update( rev=nil, **options )
		response = self.server.run( :update, rev, **options )
		self.logger.debug "Got UPDATE response: %p" % [ response ]

		return true
	end


	### Push changes to the specified +destination+.
	def push( destination=nil, **options )
		response = self.server.run( :push, destination, **options )
		self.logger.debug "Got PUSH response: %p" % [ response ]

		return true
	end


	### Name a revision using +names+.
	def tag( *names, **options )
		raise "expected at least one tag name" if names.empty?

		response = self.server.run( :tag, *names, **options )
		self.logger.debug "Got TAGS response: %p" % [ response ]

		return true
	end


	### Return a Hglib::Repo::Tag object for each tag in the repo.
	def tags
		response = self.server.run_with_json_template( :tags )
		self.logger.debug "Got a TAGS response: %p" % [ response ]

		return response.flatten.map {|tag| Hglib::Repo::Tag.new(self, **tag) }
	end


	### Create new bookmarks with the specified +names+.
	def bookmark( *names, **options )
		raise "expected at least one bookmark name" if names.empty?

		response = self.server.run( :bookmark, *names, **options )
		self.logger.debug "Got BOOKMARK response: %p" % [ response ]

		return true
	end


	### Return a Hglib::Repo::Bookmark object for each bookmark in the repo.
	def bookmarks
		options = { list: true }
		response = self.server.run_with_json_template( :bookmarks, **options )
		self.logger.debug "Got a BOOKMARKS response: %p" % [ response ]

		return response.map {|bk| Hglib::Repo::Bookmark.new(self, **bk) }
	end


	### Fetch the current global Mercurial config and return it as an Hglib::Config
	### object.
	def config( untrusted: false )
		options = { untrusted: untrusted }

		config = self.server.run_with_json_template( :showconfig, **options )
		return Hglib::Config.new( config )
	end


	### Fetch a Hash of aliases for remote repositories.
	def paths
		response = self.server.run_with_json_template( :paths )
		self.logger.debug "Got a PATHS response: %p" % [ response ]

		return response.each_with_object({}) do |entry, hash|
			hash[ entry[:name].to_sym ] = URI( entry[:url] )
		end
	end


	### Sign the given +rev+ (or the current one if not specified).
	def sign( rev=nil, **options )
		response = self.server.run( :sign, rev, **options )
		self.logger.debug "Got a SIGN response: %p" % [ response ]

		return response.chomp
	end


	### Set or show the current phase name for a +revset+.
	###
	### With no +revset+, operates on the current changeset.
	###
	### You can set the phase of the specified revisions by passing one of the
	### following +options+:
	###
	### - p: true / public: true
	### - d: true / draft: true
	### - s: true / secret: true
	###
	### Returns a Hash of <local revision number> => <phase as a Symbol>. Setting
	### the phase returns an empty Hash on success, and raises if there was a problem
	### setting the phase.
	def phase( revset=nil, **options )
		response = self.server.run( :phase, revset, **options )
		self.logger.debug "Got a PHASE response: %p" % [ response ]

		return {} if response.empty?

		return response.lines.each_with_object({}) do |line, hash|
			m = line.match( /^(?<revnum>\d+): (?<phase>\w+)/ ) or
				raise "Couldn't parse phase response %p" % [ line ]
			hash[ m[:revnum].to_i ] = m[:phase].to_sym
		end
	end


	#
	# Shortcut predicates
	#

	### Returns +true+ if the repo has outstanding changes.
	def dirty?
		return self.identify.dirty?
	end


	### Returns +true+ if the repo has no outstanding changes.
	def clean?
		return !self.dirty?
	end


	### Returns +true+ if all of the changesets in the specified +revset+ (or the
	### current changeset if no +revset+ is given) are in the public phase.
	def public?( revset=nil )
		return self.phase( revset ).values.all?( :public )
	end


	### Returns +true+ if all of the changesets in the specified +revset+ (or the
	### current changeset if no +revset+ is given) are in the draft phase.
	def draft?( revset=nil )
		return self.phase( revset ).values.all?( :draft )
	end


	### Returns +true+ if all of the changesets in the specified +revset+ (or the
	### current changeset if no +revset+ is given) are in the secret phase.
	def secret?( revset=nil )
		return self.phase( revset ).values.all?( :secret )
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


	### Return the given +string+ with the middle truncated so that it's +maxlength+
	### characters long if it exceeds that length.
	def truncate( string, maxlength=80 )
		return string if maxlength < 8
		return string if string.length - maxlength - 5 <= 0

		return string[0 .. (maxlength / 2) - 3 ] +
			' ... ' +
			string[ -((maxlength / 2) -3) .. ]
	end

end # class Hglib::Repo
