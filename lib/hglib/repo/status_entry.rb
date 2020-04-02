# -*- ruby -*-
# frozen_string_literal: true

require 'pathname'

require 'hglib/repo' unless defined?( Hglib::Repo )


# An entry in a repository's status list.
class Hglib::Repo::StatusEntry
	extend Loggability


	# Loggability API -- output to the hglib logger
	log_to :hglib


	# {
	#   :path=>"Rakefile",
	#   :status=>"M"
	# }

	### Create a new log entry from the raw +entryhash+.
	def initialize( entryhash )
		@path   = Pathname( entryhash[:path] )
		@source = Pathname( entryhash[:source] ) if entryhash.key?( :source )
		@status = entryhash[ :status ]
	end


	######
	public
	######

	##
	# Return the Pathname of the file the status applies to
	attr_reader :path

	##
	# The Pathname of the file the status applies to was copied from (if the status
	# is `A`/`added`) and the addition was via a copy/move operation.
	attr_reader :source

	##
	# Return the character that denotes the file's status
	attr_reader :status


	### Return the human-readable status.
	def status_description
		return case self.status
			when 'M' then 'modified'
			when 'A' then 'added'
			when 'R' then 'removed'
			when 'C' then 'clean'
			when '!' then 'missing'
			when '?' then 'not tracked'
			when 'I' then 'ignored'
			else
				raise "unknown status %p" % [ self.status ]
			end
	end


	### Returns +true+ if the status is 'modified'.
	def modified?
		return self.status == 'M'
	end


	### Returns +true+ if the status is 'added'.
	def added?
		return self.status == 'A'
	end


	### Returns +true+ if the status is 'removed'.
	def removed?
		return self.status == 'R'
	end


	### Returns +true+ if the status is 'clean'.
	def clean?
		return self.status == 'C'
	end


	### Returns +true+ if the status is 'missing'.
	def missing?
		return self.status == '!'
	end


	### Returns +true+ if the status is 'not tracked'.
	def not_tracked?
		return self.status == '?'
	end
	alias_method :untracked?, :not_tracked?


	### Returns +true+ if the status is anything other than 'not tracked'.
	def tracked?
		return !self.not_tracked?
	end


	### Returns +true+ if the status is 'ignored'.
	def ignored?
		return self.status == 'I'
	end


	### Return a human-readable representation of the StatusEntry as a String.
	def inspect
		return "#<%p:#%x %s: %s%s>" % [
			self.class,
			self.object_id * 2,
			self.path,
			self.status_description,
			self.source ? " via copy/move from #{self.source}" : '',
		]
	end

end # class Hglib::Repo::StatusEntry

