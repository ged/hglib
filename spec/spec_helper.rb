# -*- ruby -*-
#encoding: utf-8

require 'simplecov' if ENV['COVERAGE']
require 'tmpdir'
require 'rspec'

require 'loggability/spechelpers'

require 'hglib'

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
	config.profile_examples = 5
	config.order = :random

	Kernel.srand( config.seed )

	# Try environment variables if `hg` isn't in the PATH
	if !Hglib.hg_path.executable?
		Hglib.hg_path = ENV['HG_BINARY'] if ENV['HG_BINARY']
		Hglib.hg_path = ENV['TM_HG'] if ENV['TM_HG']
	end
	config.filter_run_excluding( :requires_binary ) unless Hglib.hg_path.executable?

	config.include( Loggability::SpecHelpers )
end
