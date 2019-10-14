# -*- ruby -*-
#encoding: utf-8

require 'tmpdir'

require 'loggability/spechelpers'
require 'rspec'
require 'hglib'


module Hglib::IntegrationSpecHelpers

	### Inclusion hook -- set up variables before each run.
	def self::included( context )
		context.before( :each ) do
			@file_counter = 0
		end
	end


	### Add +count+ files to the repo.
	def add_files( repo_dir, count=rand(1..5) )
		return count.times.map do
			filename = "file-%03d" % [ @file_counter ]
			file_path = repo_dir + filename

			Loggability[ Hglib ].debug "Writing %s" % [ file_path ]
			file_path.write( SecureRandom.base64(128) )

			@file_counter += 1
			file_path
		end
	end


	### Make a commit in the specified +repo+.
	def make_a_commit( repo )
		files = add_files( repo.path )

		repo.add
		repo.commit( message: "Creating a commit with %d files" % [ files.length ] )
	end



end # module Hglib::IntegrationSpecHelpers


RSpec.configure do |config|
	config.expect_with :rspec do |expectations|
		expectations.include_chain_clauses_in_custom_matcher_descriptions = true
	end

	config.mock_with :rspec do |mocks|
		mocks.verify_partial_doubles = true
	end

	config.shared_context_metadata_behavior = :apply_to_host_groups
	config.filter_run_when_matching :focus
	config.example_status_persistence_file_path = "spec/.status"
	config.disable_monkey_patching!
	config.warnings = true
	config.profile_examples = 10
	config.order = :random

	# Try environment variables if `hg` isn't in the PATH
	if !Hglib.hg_path.executable?
		Hglib.hg_path = ENV['HG_BINARY'] if ENV['HG_BINARY']
		Hglib.hg_path = ENV['TM_HG'] if ENV['TM_HG']
	end

	Kernel.srand( config.seed )
	config.include( Loggability::SpecHelpers )
	config.include( Hglib::IntegrationSpecHelpers )
end
