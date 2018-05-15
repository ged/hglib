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

		expect( server ).to receive( :run ).with( :log, {} ).
			and_return([
				"changeset:   1:81f357f730d9\n"\
				"user:        Michael Granger <ged@FaerieMUD.org>\n"\
				"date:        Wed Jan 24 08:41:13 2018 -0800\n"\
				"summary:     Make ruby-version less specific\n\n",

				"changeset:   0:d6c97f99b012\n"\
				"user:        Michael Granger <ged@FaerieMUD.org>\n"\
				"date:        Wed Jan 24 08:25:21 2018 -0800\n"\
				"summary:     Initial commit.\n\n"
			])

		result = repo.log

		expect( result ).to be_an( Array ).and( all be_a(Hglib::Repo::LogEntry) )
	end

end

