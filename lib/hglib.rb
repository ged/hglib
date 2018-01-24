# -*- ruby -*-
#encoding: utf-8

require 'pathname'

# Toplevel namespace
module Hglib

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


	### Return the currently-configured path to the `hg` binary./
	def self::hg_path
		return @hg_path ||= DEFAULT_HG_PATH
	end


	### Set the path to the `hg` binary that will be used for any new commands.
	def self::hg_path=( new_path )
		@hg_path = Pathname( new_path )
	end

end # module Hglib

