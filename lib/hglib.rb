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
	VERSION = '0.0.1'

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


	### Return an Hglib::Repo object for the specified +path+.
	def self::repo( path='.' )
		return Hglib::Repo.new( path )
	end


	### Clone the +remote_repo+ to the specified +local_dir+, which defaults to a
	### directory with the basename of the +remote_repo+ in the current working
	### directory.
	def self::clone( remote_repo, local_dir=nil )
		output = self.server( nil ).run( :clone, remote_repo, local_dir )
		self.log.debug "Clone output: %s" % [ output ]

		local_dir ||= Pathname.pwd + File.basename( remote_repo )
		return self.repo( local_dir )
	end

end # module Hglib

