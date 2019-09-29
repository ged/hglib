#!/usr/bin/env rspec -cfd

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

end

