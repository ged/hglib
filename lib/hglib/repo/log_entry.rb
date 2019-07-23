# -*- ruby -*-
# frozen_string_literal: true

require 'time'

require 'hglib/repo' unless defined?( Hglib::Repo )


# An entry in a repository's revision log.
class Hglib::Repo::LogEntry
	extend Loggability


	# Loggability API -- output to the hglib logger
	log_to :hglib


	# {
	# 	"bookmarks" => [],
	# 	"branch" => "default",
	# 	"date" => [1527021225, 25200],
	# 	"desc" => "Add Assemblage commit script",
	# 	"node" => "4a1cbb9f8d56abd4e72aa2860eecef718dad48dd",
	# 	"parents" => ["ac2b07cce0fc307e787a91b9e74b4514f7b71f09"],
	# 	"phase" => "draft",
	# 	"rev" => 7,
	# 	"tags" => [],
	# 	"user" => "Michael Granger <ged@FaerieMUD.org>"
	# }

	### Create a new log entry from the raw +entryhash+.
	def initialize( entryhash )
		@bookmarks = entryhash[ :bookmarks ]
		@branch    = entryhash[ :branch ]
		@date      = entryhash[ :date ]
		@desc      = entryhash[ :desc ]
		@node      = entryhash[ :node ]
		@parents   = entryhash[ :parents ]
		@phase     = entryhash[ :phase ]
		@rev       = entryhash[ :rev ]
		@tags      = entryhash[ :tags ]
		@user      = entryhash[ :user ]
		@date      = entryhash[ :date ]
		@files     = entryhash[ :files ] || []
	end


	######
	public
	######

	##
	# Return the Array of bookmarks corresponding to the entry (if any)
	attr_reader :bookmarks

	##
	# Return the name of the branch the commit is on
	attr_reader :branch

	##
	# Return the description from the entry
	attr_reader :desc
	alias_method :summary, :desc

	##
	# Return the node (changeset ID) from the entry
	attr_reader :node

	##
	# Return the changeset IDs of the parents of the entry
	attr_reader :parents

	##
	# Return the phase from the entry
	attr_reader :phase

	##
	# Return the revision number from the entry
	attr_reader :rev

	##
	# Return the Array of the entry's tags
	attr_reader :tags

	##
	# Return the name and email of the committing user
	attr_reader :user

	##
	# The diff of the commit, if --patch was specified.
	attr_reader :diff

	##
	# The files affected by the commit, if run with `verbose: true`.
	attr_reader :files


	### The Time the revision associated with the entry was committed
	def date
		return Time.at( @date[0] )
	end
	alias_method :time, :date


	### Return the shortened changeset ID (in the form {rev}:{shortnode})
	def changeset
		return "%d:%s" % [ self.rev, self.node[0,12] ]
	end


	### Return a human-readable representation of the LogEntry as a String.
	def inspect
		parts = []
		parts += self.tags.map {|t| "##{t}" }
		parts += self.bookmarks.map {|b| "@#{b}" }

		return "#<%p:#%x %s {%s} %p%s>" % [
			self.class,
			self.object_id * 2,
			self.changeset,
			self.date,
			self.summary,
			parts.empty? ? '' : " " + parts.join(' ')
		]
	end

end # class Hglib::Repo::LogEntry

