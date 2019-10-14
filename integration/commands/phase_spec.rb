#!/usr/bin/env ruby -S rspec -cfd

require 'securerandom'
require_relative '../spec_helper'

RSpec.describe "phase manipulation" do

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


	it "can change the phase of the current revision" do
		5.times { make_a_commit(repo) }

		phases = repo.phase( '4:0' )

		expect( phases ).to eq( {4 => :draft, 3 => :draft, 2 => :draft, 1 => :draft, 0 => :draft} )
	end
end

