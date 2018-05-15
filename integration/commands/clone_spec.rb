#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

RSpec.describe "cloning" do

	let( :repo_dir ) do
		dir = Dir.mktmpdir( ['hglib', 'repodir'] )
		Pathname( dir )
	end


	after( :each ) do
		repo_dir.rmtree if repo_dir.exist?
	end


	it "can clone a local repo with no options" do
		repo = Hglib.clone( '.', repo_dir )

		expect( repo ).to be_a( Hglib::Repo )
		expect( repo.path ).to eq( repo_dir )
		expect( repo.status ).to be_empty
		expect( repo_dir.children(false) ).to include(
			Pathname( '.hg' ),
			Pathname( 'Rakefile' )
		)
	end


	it "can clone without updating" do
		repo = Hglib.clone( '.', repo_dir, noupdate: true )

		expect( repo ).to be_a( Hglib::Repo )
		expect( repo.path ).to eq( repo_dir )
		expect( repo.status ).to be_empty
		expect( repo.id ).to eq( '000000000000' )
		expect( repo_dir.children(false) ).to contain_exactly( Pathname('.hg') )
	end


	it "can clone to a specific revision" do
		repo = Hglib.clone( '.', repo_dir, rev: 'da8322c8b033' )

		expect( repo ).to be_a( Hglib::Repo )
		expect( repo.path ).to eq( repo_dir )
		expect( repo.status ).to be_empty
		expect( repo.id ).to eq( 'da8322c8b033' )
	end

end

