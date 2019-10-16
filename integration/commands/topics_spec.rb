#!/usr/bin/env ruby -S rspec -cfd

require 'securerandom'
require_relative '../spec_helper'

RSpec.describe "topics extension" do

	let( :repo_dir ) do
		dir = Dir.mktmpdir( ['hglib', 'repodir'] )
		Pathname( dir )
	end
	let( :repo ) do
		Hglib.init( repo_dir )
	end


	after( :each ) do
		repo_dir.rmtree if repo_dir.exist?
	end


	it "can create a new topic" do
		repo.topic( 'integration-test-1' )
		topics = repo.topics

		expect( topics.length ).to eq( 1 )
		expect( topics.last ).to have_attributes(
			name: 'integration-test-1',
			branch: 'default',
			changeset_count: 0
		)

		make_a_commit( repo )

		expect( repo.topic ).to eq( 'integration-test-1' )

		topics = repo.topics
		expect( topics.length ).to eq( 1 )
		expect( topics.last ).to have_attributes(
			name: 'integration-test-1',
			branch: 'default',
			changeset_count: 1
		)

		repo.topic( 'integration-test-2' )
		4.times { make_a_commit( repo ) }

		expect( repo.topic ).to eq( 'integration-test-2' )

		topics = repo.topics
		expect( topics.length ).to eq( 2 )
		expect( topics.last ).to have_attributes(
			name: 'integration-test-2',
			branch: 'default',
			changeset_count: 4
		)
	end

end

