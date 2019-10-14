# -*- ruby -*-
# frozen_string_literal: true

require 'pathname'
require 'loggability'

require 'hglib' unless defined?( Hglib )


module Hglib::Extension
	extend Loggability

	# Loggability API -- log to the Hglib logger
	log_to :hglib


	### Load all of the extensions.
	def self::load_all
		# :TODO: Allow gem extensions?
		extdir = Pathname( __FILE__ ).dirname + 'extension'
		Pathname.glob( extdir + '*.rb' ).each do |extpath|
			self.log.debug "Loading extensions from %s" % [ extpath ]
			require( extpath )
		end
	end


	### Define one or more commands that should be attached to Repo objects.
	def repo_commands( &block )
		raise LocalJumpError, "no block given" unless block

		mod = Module.new
		mod.class_eval( &block )

		Hglib::Repo.include( mod )
	end


	### Define one or more commands that should be attached to the Hglib module.
	def global_commands( &block )
		raise LocalJumpError, "no block given" unless block

		mod = Module.new
		mod.class_eval( &block )

		Hglib.extend( mod )
	end

end # module Hglib::Extension

