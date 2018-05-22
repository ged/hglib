#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'hglib/repo/log_entry'


RSpec.describe Hglib::Repo::LogEntry do

	RAW_LOG_OUTPUT = (<<-END_LOG_OUTPUT).gsub( /^\t/, '' )
	changeset:   5:d4af915821de
	bookmark:    master
	tag:         github/master
	tag:         tip
	user:        Michael Granger <ged@FaerieMUD.org>
	date:        Tue May 15 14:40:46 2018 -0700
	summary:     Flesh out the features of Repo objects

	END_LOG_OUTPUT


	it "can parse the raw output from the `log` command" do
		entry = described_class.parse( RAW_LOG_OUTPUT )

		expected_time = Time.parse( 'Tue May 15 14:40:46 2018 -0700' )

		expect( entry ).to be_a( described_class )
		expect( entry.changeset ).to eq( '5:d4af915821de' )
		expect( entry.bookmarks ).to contain_exactly( 'master' )
		expect( entry.tags ).to contain_exactly( 'github/master', 'tip' )
		expect( entry.user ).to eq( 'Michael Granger <ged@FaerieMUD.org>' )
		expect( entry.date ).to be_a( Time ).and( eq(expected_time) )
		expect( entry.summary ).to eq( 'Flesh out the features of Repo objects' )

		expect( entry.body ).to be_nil
	end

end

