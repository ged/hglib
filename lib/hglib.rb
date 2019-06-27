# -*- ruby -*-
# frozen_string_literal: true

require 'e2mmap'
require 'loggability'
require 'pathname'


# Toplevel namespace
module Hglib
	extend Loggability,
	       Exception2MessageMapper

	# Package version
	VERSION = '0.2.0'

	# Version control revision
	REVISION = %q$Revision$

	# The default path to the `hg` command
	DEFAULT_HG_PATH = begin
		paths = ENV['PATH'].
			split( File::PATH_SEPARATOR ).
			map {|dir| Pathname(dir) + 'hg' }

		paths.find( &:executable? ) || Pathname( '/usr/bin/hg' )
	end


	# Base exception class for errors raised by this library
	def_exception :Error, "hglib error"
	def_exception :CommandError, "error in hg command", Hglib::Error

	# Loggability API -- set up a Logger for Hglib objects
	log_as :hglib


	### Return the currently-configured path to the `hg` binary./
	def self::hg_path
		return @hg_path ||= DEFAULT_HG_PATH
	end


	### Set the path to the `hg` binary that will be used for any new commands.
	def self::hg_path=( new_path )
		@hg_path = Pathname( new_path )
	end


	# Set up automatic loading of submodules
	autoload :Server, 'hglib/server'
	autoload :Repo, 'hglib/repo'


	### Return an Hglib::Server set to use the current ::hg_path, creating one if
	### necessary.
	def self::server( repo='.' )
		@hg_servers ||= {}
		return @hg_servers[ repo ] ||= Hglib::Server.new( repo )
	end


	### Returns +true+ if the specified +dir+ looks like it is a Mercurial
	### repository.
	def self::is_repo?( dir )
		dir = Pathname( dir )
		hgdir = dir + '.hg'
		return dir.directory? && hgdir.directory?
	end


	### Return an Hglib::Repo object for the specified +path+.
	def self::repo( path='.' )
		return Hglib::Repo.new( path )
	end


	### Clone the +source_repo+ to the specified +local_dir+, which defaults to a
	### directory with the basename of the +source_repo+ in the current working
	### directory.
	def self::clone( source_repo, local_dir=nil, **options )
		output = self.server( nil ).run( :clone, source_repo, local_dir, **options )
		self.log.debug "Clone output: %s" % [ output ]

		local_dir ||= Pathname.pwd + File.basename( source_repo )
		return self.repo( local_dir )
	end


	### Initialize a repository in the given +dir+ and return a Hglib::Repo
	### for it.
	def self::init( dir, **options )
		output = self.server( nil ).run( :init, dir, **options )
		self.log.debug "Init output: %s" % [ output ]

		return self.repo( dir )
	end

end # module Hglib

