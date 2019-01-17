#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'hglib/repo'


RSpec.describe Hglib::Repo do

	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end

	let( :server ) { instance_double(Hglib::Server) }


	before( :each ) do
		allow( Hglib::Server ).to receive( :new ).and_return( server )
	end


	it "can fetch the status of the working directory" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :status, {} ).
			and_return([
				"M ",
				".gems\n",
				"M ",
				"lib/hglib/repo.rb\n",
				"M ",
				"lib/hglib/server.rb\n",
				"? ",
				"coverage/assets/0.10.2/magnify.png\n"
			])

		result = repo.status

		expect( result ).to be_a( Hash )
		expect( result ).to include(
			Pathname('.gems') => 'M',
			Pathname('lib/hglib/repo.rb') => 'M',
			Pathname('lib/hglib/server.rb') => 'M',
			Pathname('coverage/assets/0.10.2/magnify.png') => '?'
		)
	end


	it "can fetch the identification of the repository's current revision" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :id, {} ).
			and_return( ["80d775fc1d2c+ qbase/qtip/repo-features.patch/tip master\n"] )

		result = repo.id

		expect( result ).to be_a( Hglib::Repo::Id ).and( eq '80d775fc1d2c' )
		expect( result.tags ).to eq( %w[qbase qtip repo-features.patch tip] )
		expect( result.bookmarks ).to eq( %w[master] )
	end


	it "can fetch the log of the repository" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :log, {T: 'json', graph: false} ).
			and_return([
				"[",
				"\n {\n  \"bookmarks\": [],\n  \"branch\": \"default\",\n  \"date\": " +
				"[1516812073, 28800],\n  \"desc\": \"Make ruby-version less specific\"," +
				"\n  \"node\": \"81f357f730d9f22d560e4bd2790e7cf5aa5b7ec7\",\n  \"parents\":" +
				" [\"d6c97f99b012199d9088e85bb0940147446c6a87\"],\n  \"phase\": \"public\",\n " +
				" \"rev\": 1,\n  \"tags\": [],\n  \"user\": \"Michael Granger" +
				" <ged@FaerieMUD.org>\"\n }",
				",",
				"\n {\n",
				"  \"bookmarks\": []",
				",\n",
				"  \"branch\": \"default\"",
				",\n",
				"  \"date\": [1516811121, 28800]",
				",\n",
				"  \"desc\": \"Initial commit.\"",
				",\n",
				"  \"node\": \"d6c97f99b012199d9088e85bb0940147446c6a87\"",
				",\n",
				"  \"parents\": [\"0000000000000000000000000000000000000000\"]",
				",\n",
				"  \"phase\": \"public\"",
				",\n",
				"  \"rev\": 0",
				",\n",
				"  \"tags\": []",
				",\n",
				"  \"user\": \"Michael Granger <ged@FaerieMUD.org>\"",
				"\n }",
				"\n]\n"
			])

		result = repo.log

		expect( result ).to be_an( Array ).and( all be_a(Hglib::Repo::LogEntry) )
	end

end

