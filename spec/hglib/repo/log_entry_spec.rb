#!/usr/bin/env rspec -cfd
# frozen_string_literal: true

require_relative '../../spec_helper'

require 'hglib/repo/log_entry'


RSpec.describe Hglib::Repo::LogEntry do

	RAW_LOG_ENTRY = {
		"bookmarks" => ['master'],
		"branch"    => "default",
		"date"      => [1526420446, 25200],
		"desc"      => "Flesh out the features of Repo objects",
		"node"      => "d4af915821dea2feca29288dc16742c0d41cee8c",
		"parents"   => ["a366819bd05b8dd995440105340e057528be25e6"],
		"phase"     => "public",
		"rev"       => 5,
		"tags"      => ['github/master', 'tip'],
		"user"      => "Michael Granger <ged@FaerieMUD.org>"
	}.freeze

	VERBOSE_LOG_ENTRY = RAW_LOG_ENTRY.merge(
		"files"     => %w[.hoerc .ruby-version lib/hglib/repo.rb spec/hglib/repo_spec.rb]
	).freeze


	it "can be created from the JSON log hash" do
		entry = described_class.new( RAW_LOG_ENTRY )

		expected_time = Time.parse( 'Tue May 15 14:40:46 2018 -0700' )

		expect( entry ).to be_a( described_class )
		expect( entry.changeset ).to eq( '5:d4af915821de' )
		expect( entry.rev ).to eq( 5 )
		expect( entry.node ).to eq( 'd4af915821dea2feca29288dc16742c0d41cee8c' )
		expect( entry.bookmarks ).to contain_exactly( 'master' )
		expect( entry.tags ).to contain_exactly( 'github/master', 'tip' )
		expect( entry.user ).to eq( 'Michael Granger <ged@FaerieMUD.org>' )
		expect( entry.date ).to be_a( Time ).and( eq(expected_time) )
		expect( entry.summary ).to eq( 'Flesh out the features of Repo objects' )

		expect( entry.diff ).to be_nil
		expect( entry.files ).to be_empty
	end


	it "can be created from verbose log entry JSON" do
		entry = described_class.new( VERBOSE_LOG_ENTRY )

		expected_time = Time.parse( 'Tue May 15 14:40:46 2018 -0700' )

		expect( entry ).to be_a( described_class )
		expect( entry.changeset ).to eq( '5:d4af915821de' )
		expect( entry.rev ).to eq( 5 )
		expect( entry.node ).to eq( 'd4af915821dea2feca29288dc16742c0d41cee8c' )
		expect( entry.bookmarks ).to contain_exactly( 'master' )
		expect( entry.tags ).to contain_exactly( 'github/master', 'tip' )
		expect( entry.user ).to eq( 'Michael Granger <ged@FaerieMUD.org>' )
		expect( entry.date ).to be_a( Time ).and( eq(expected_time) )
		expect( entry.summary ).to eq( 'Flesh out the features of Repo objects' )

		expect( entry.diff ).to be_nil
		expect( entry.files ).to contain_exactly( *VERBOSE_LOG_ENTRY['files'] )
	end

end

