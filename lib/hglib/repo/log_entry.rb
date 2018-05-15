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

	### Parse a new LogEntry from the raw_entry (a UTF-8 String)
	def self::parse( raw_entry )
		raw_metadata, body = raw_entry.split( "\n\n" )
		metadata = raw_metadata.each_line.inject({}) do |hash, line|
			key, value = line.split( /:\s*/, 2 )
			key = key.to_sym

			if hash.key?( key )
				hash[ key ] = Array( hash[key] )
				hash[ key ].push( value )
			else
				hash[ key ] = value
			end
		end

		return self.new( )
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
	def self::def_metadata_reader( *names )
		names.each do |name|
			reader = lambda { self.metadata[name] }
			define_method( name, &reader )
		end
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


	### The Time the revision associated with the entry was committed
	def date
		return Time.parse( self.metadata[:date] )
	end

end # class Hglib::Repo::LogEntry

