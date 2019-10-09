# -*- ruby -*-
# frozen_string_literal: true

require 'hglib/repo' unless defined?( Hglib::Repo )
require 'hglib/mixins'


# The identification of a particular revision of a repository.
class Hglib::Repo::Id
	extend Hglib::MethodUtilities


	# The SHA of the zeroth node
	DEFAULT_ID = '0000000000000000000000000000000000000000'

	# The default branch name to use
	DEFAULT_BRANCH = 'default'

	# The SHA of the node when the repo is at tip
	DEFAULT_NODE = 'ffffffffffffffffffffffffffffffffffffffff'


	### Create a new repository ID with the given +global+ revision identifier, one
	### or more +tags+, and other options.
	def initialize( id:, branch: DEFAULT_BRANCH, node: DEFAULT_NODE, dirty: false,
		parents: [], tags: [], bookmarks: [] )

		@id = id[ /\p{XDigit}{40}/ ]
		@branch = branch
		@node = node
		@dirty = dirty == '+'
		@tags = Array( tags )
		@parents = Array( parents )
		@bookmarks = Array( bookmarks )
	end


	######
	public
	######

	##
	# The long-form revision ID
	attr_reader :id
	alias_method :global, :id

	##
	# The name of the current branch
	attr_reader :branch

	##
	# The ID of the current changeset node
	attr_reader :node

	##
	# The current IDs of the current revision's parent(s).
	attr_reader :parents

	##
	# Does the repo have uncommitted changes?
	attr_predicate :dirty
	alias_method :uncommitted_changes?, :dirty?
	alias_method :has_uncommitted_changes?, :dirty?

	##
	# The tags belonging to the revision of the repo.
	attr_reader :tags

	##
	# The bookmarks set on the revision of the repo.
	attr_reader :bookmarks


	### Return the short form of the global ID.
	def short_id
		return self.id[ 0, 12 ]
	end


	### Return the ID as a String in the form used by the command line.
	def to_s
		str = self.global.dup

		str << '+' if self.uncommitted_changes?
		str << ' ' << self.tags.join( '/' ) unless self.tags.empty?
		str << ' ' << self.bookmarks.join( '/' ) unless self.bookmarks.empty?

		return str
	end


	### Comparison operator -- returns +true+ if the +other+ object is another
	### Hglib::Repo::Id with the same values, or a String containing the #global
	### revision identifier.
	def ==( other )
		return (other.is_a?( self.class ) && self.to_s == other.to_s) ||
			self.global == other
	end


	### Returns +true+ if the Id's revision ID is the DEFAULT_ID
	def default?
		return self.id == DEFAULT_ID
	end

end # class Hglib::Repo::Id

