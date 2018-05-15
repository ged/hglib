# -*- ruby -*-
# frozen_string_literal: true

require 'hglib/repo' unless defined?( Hglib::Repo )


# The identification of a particular revision of a repository.
class Hglib::Repo::Id

	### Parse the given +raw_id+ and return a new Id that contains the parsed
	### information.
	def self::parse( raw_id )
		global, tags, bookmarks = raw_id.chomp.split( ' ', 3 )
		has_plus = global.chomp!( '+' ) ? true : false

		tags ||= ''
		tags = tags.split( '/' )

		bookmarks ||= ''
		bookmarks = bookmarks.split( '/' )

		return self.new( global, *tags, uncommitted_changes: has_plus, bookmarks: bookmarks )
	end


	### Create a new repository ID with the given +global+ revision identifier, one
	### or more +tags+, and other options.
	def initialize( global, *tags, uncommitted_changes: false, bookmarks: [] )
		@global = global
		@tags = tags
		@bookmarks = Array( bookmarks )
		@uncommitted_changes = uncommitted_changes
	end


	######
	public
	######

	##
	# The repo's global (short-form) revision identifier.
	attr_reader :global

	##
	# The tags belonging to the revision of the repo.
	attr_reader :tags

	##
	# The bookmarks set on the revision of the repo.
	attr_reader :bookmarks


	### Returns +true+ if the repo's working directory has uncommitted changes.
	def uncommitted_changes?
		return @uncommitted_changes
	end
	alias_method :has_uncommitted_changes?, :uncommitted_changes?


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

