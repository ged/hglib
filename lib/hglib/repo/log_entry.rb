# -*- ruby -*-
# frozen_string_literal: true

require 'time'

require 'hglib/repo' unless defined?( Hglib::Repo )


# changeset:   1:81f357f730d9
# user:        Michael Granger <ged@FaerieMUD.org>
# date:        Wed Jan 24 08:41:13 2018 -0800
# summary:     Make ruby-version less specific
#
# changeset:   0:d6c97f99b012
# user:        Michael Granger <ged@FaerieMUD.org>
# date:        Wed Jan 24 08:25:21 2018 -0800
# summary:     Initial commit.

# An entry in a repository's revision log.
class Hglib::Repo::LogEntry
	extend Loggability


	# Loggability API -- output to the hglib logger
	log_to :hglib


	### Parse a new LogEntry from the raw_entry (a UTF-8 String)
	def self::parse( raw_entry )
		header, body = raw_entry.split( "\n\n" )
		metadata = self.parse_log_header( header )

		return self.new( metadata, body )
	end


	### Parse the given log +header+ and return the metadata from it as a Hash.
	def self::parse_log_header( header )

		# Ensure bookmarks and tags are always an array
		metadata = { tag: [], bookmark: [] }

		return header.each_line.with_object( metadata ) do |line, hash|
			key, value = line.split( /:\s*/, 2 )
			key = key.to_sym

			if hash.key?( key )
				hash[ key ] = Array( hash[key] )
				hash[ key ].push( value.strip )
			else
				hash[ key ] = value.strip
			end
		end
	end


	### Create a new log entry.
	def initialize( metadata, body=nil )
		@metadata  = metadata
		@body      = body
	end


	######
	public
	######

	##
	# The parsed headers of the entry
	attr_reader :metadata

	##
	# The body of the log entry (e.g., the diff in --patch mode)
	attr_reader :body


	### Declare a reader for a value of the metadata.
	def self::def_metadata_reader( method_name, key=method_name )
		reader = lambda { self.metadata[key] }
		define_method( method_name, &reader )
	end


	##
	# The short-form identifier for the entry's revision
	def_metadata_reader :changeset

	##
	# The user that committed the entry's revision
	def_metadata_reader :user

	##
	# The log summary for the entry
	def_metadata_reader :summary

	##
	# The tags associated with the entry's revision
	def_metadata_reader :tags, :tag

	##
	# The bookmarks currently associated with the entry's revision
	def_metadata_reader :bookmarks, :bookmark


	### The Time the revision associated with the entry was committed
	def date
		return Time.parse( self.metadata[:date] )
	end
	alias_method :time, :date


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

