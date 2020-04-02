#!/usr/bin/env ruby -S rspec -cfd

require_relative '../../spec_helper'

require 'hglib/repo/status_entry'


RSpec.describe Hglib::Repo::StatusEntry do

	RAW_STATUS_ENTRY = {
		path: 'Rakefile',
		status: 'M',
	}.freeze

	RAW_COPY_STATUS_ENTRY = {
		path: "AnotherRakefile",
		source: "Rakefile",
		status: "A"
	}

	it "can be created from the JSON status hash" do
		entry = described_class.new( RAW_STATUS_ENTRY )

		expect( entry ).to be_a( described_class )
		expect( entry.path ).to eq( Pathname('Rakefile') )
		expect( entry.status ).to eq( 'M' )
		expect( entry.status_description ).to eq( 'modified' )
	end


	it "can be created from the JSON status hash run with --copies enabled" do
		entry = described_class.new( RAW_COPY_STATUS_ENTRY )

		expect( entry ).to be_a( described_class )
		expect( entry.path ).to eq( Pathname('AnotherRakefile') )
		expect( entry.status ).to eq( 'A' )
		expect( entry.source ).to eq( Pathname('Rakefile') )
		expect( entry.status_description ).to eq( 'added' )
	end


	it "knows if its file has been modified" do
		entry = described_class.new( RAW_STATUS_ENTRY )
		expect( entry ).to be_modified
	end

	# when 'A' then 'added'
	# when 'R' then 'removed'
	# when 'C' then 'clean'
	# when '!' then 'missing'
	# when '?' then 'not tracked'
	# when 'I' then 'ignored'

	it "knows if its file has been scheduled for removal" do
		entry = described_class.new( RAW_STATUS_ENTRY.merge(status: 'R') )
		expect( entry ).to be_removed
	end


	it "knows if its file is clean" do
		entry = described_class.new( RAW_STATUS_ENTRY.merge(status: 'C') )
		expect( entry ).to be_clean
	end


	it "knows if its file is missing" do
		entry = described_class.new( RAW_STATUS_ENTRY.merge(status: '!') )
		expect( entry ).to be_missing
	end


	it "knows if its file is untracked" do
		entry = described_class.new( RAW_STATUS_ENTRY.merge(status: '?') )
		expect( entry ).to be_untracked
	end


	it "knows if its file is tracked" do
		entry = described_class.new( RAW_STATUS_ENTRY )
		expect( entry ).to be_tracked
	end


	it "knows if its file is ignored" do
		entry = described_class.new( RAW_STATUS_ENTRY.merge(status: 'I') )
		expect( entry ).to be_ignored
	end

end

