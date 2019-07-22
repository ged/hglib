# -*- ruby -*-
# frozen_string_literal: true

require 'hglib/repo' unless defined?( Hglib::Repo )
require 'hglib/mixins'


# The identification of a particular revision of a repository.
class Hglib::Repo::Id
	extend Hglib::MethodUtilities


	### Create a new repository ID with the given +global+ revision identifier, one
	### or more +tags+, and other options.
	def initialize( id:, branch:, node:, dirty: false, parents: [], tags: [], bookmarks: [] )
		@id = id
		@branch = branch
		@node = node
		@dirty = dirty
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

	##
	# The name of the current branch
	attr_reader :branch

	##
	# The ID of the current
	attr_reader :node

	##
	# The current IDs of the current revision's parent(s).
	attr_reader :parents

	##
	# Does the repo have uncommitted changes?
	attr_predicate :dirty
	alias_method :dirty?, :uncommitted_changes?
	alias_method :dirty?, :has_uncommitted_changes?

	##
	# The tags belonging to the revision of the repo.
	attr_reader :tags

	##
	# The bookmarks set on the revision of the repo.
	attr_reader :bookmarks


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

end # class Hglib::Repo::Id

