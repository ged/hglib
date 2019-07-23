# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'hglib/repo' unless defined?( Hglib::Repo )
require 'hglib/mixins'


class Hglib::Repo::Bookmark
	extend Loggability,
		Hglib::MethodUtilities


	# Send logs to Hglib's logger
	log_to :hglib


	# {
	# 	"active"   => true,
	# 	"bookmark" => "master",
	# 	"node"     => "720c115412188539039b87baf57931fb5415a0bf",
	# 	"rev"      => 26
	# }

	### Create a new Bookmark with the given values.
	def initialize( repo, bookmark:, node:, rev:, active: false  )
		@repo   = repo
		@name   = bookmark
		@node   = node
		@rev    = rev
		@active = active
	end


	######
	public
	######

	##
	# The Hglib::Repo the bookmark lives in
	attr_reader :repo

	##
	# The name of the bookmark
	attr_reader :name

	##
	# The SHA of the commit the bookmark is currently on
	attr_reader :node

	##
	# The revision number of the commit the bookmark is currently on
	attr_reader :rev

	##
	# Whether or not the bookmark is currently active
	attr_predicate :active


	### Delete the bookmark from its repository.
	def delete
		return self.repo.bookmark( self.name, delete: true )
	end


	### Move the bookmark to the specified +revision+.
	def move_to( revision )
		return self.repo.bookmark( self.name, rev: revision, force: true )
	end


end # class Hglib::Repo::Bookmark


