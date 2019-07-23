# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'

require 'hglib/repo' unless defined?( Hglib::Repo )


class Hglib::Repo::Tag
	extend Loggability


	# Send logs to the Hglib logger
	log_to :hglib


	### Create a tag object.
	def initialize( repo, tag:, node:, rev: 0, type: '' )
		@repo = repo
		@name = tag
		@node = node
		@rev  = rev
		@type = type
	end


	######
	public
	######

	##
	# The repo the tag belongs to
	attr_reader :repo

	##
	# The tag's name
	attr_reader :name

	##
	# The SHA of the node the tag points to
	attr_reader :node

	##
	# The numeric revision the tag points to
	attr_reader :rev

	##
	# The tag type
	attr_reader :type

end # class Hglib::Repo::Tag

