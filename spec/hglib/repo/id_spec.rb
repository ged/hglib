#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'securerandom'
require 'pathname'
require 'hglib/repo/id'


RSpec.describe Hglib::Repo::Id, :requires_binary do

	let( :repo_dir ) do
		Pathname( Dir.mktmpdir(['hglib', 'repodir']) )
	end
	let( :repo ) { Hglib.init(repo_dir) }
	let( :fake_sha ) { Random.bytes(20).unpack1('h*') }


	it "can be created for an empty repo" do
		result = repo.id

		expect( result.id ).to eq( described_class::DEFAULT_ID )
		expect( result ).to eq( described_class::DEFAULT_ID )
		expect( result.parents ).to contain_exactly( described_class::DEFAULT_ID )
		expect( result.branch ).to eq( described_class::DEFAULT_BRANCH )
		expect( result.node ).to eq( described_class::DEFAULT_NODE )
		expect( result.tags ).to contain_exactly( 'tip' )
		expect( result.bookmarks ).to be_empty
		expect( result ).to_not have_uncommitted_changes
	end


	it "can be created for a repo with commits" do
		newfile = repo_dir + 'README.md'
		newfile.write( <<~END_OF_FILE )
		There is nothing to see here.
		END_OF_FILE

		repo.addr
		repo.commit( message: "Add stuff." )

		result = repo.id

		expect( result.id ).to match( /\A\p{XDigit}{40}\z/ )
		expect( result.tags ).to contain_exactly( 'tip' )
		expect( result.bookmarks ).to be_empty
		expect( result ).to_not have_uncommitted_changes
	end


	it "can be created for a repo with uncommitted changes" do
		newfile = repo_dir + 'README.md'
		newfile.write( <<~END_OF_FILE )
		There is more nothing to see here.
		END_OF_FILE

		repo.add
		result = repo.id

		expect( result.id ).to match( /\A\p{XDigit}{40}\z/ )
		expect( result ).to have_uncommitted_changes
	end


	describe "equality" do

		it "is equal to an object of the same class with the same values" do
			id = described_class.new(
				id: fake_sha,
				tags: ['qbase', 'qtip', 'repo-features.patch', 'tip'],
				dirty: '+',
				bookmarks: ['master', 'live']
			)

			copy = id.dup

			expect( id ).to eq( copy )
		end


		it "is equal to the String that contains the same revision identifier" do
			id = described_class.new( id: fake_sha )

			expect( id ).to eq( fake_sha )
		end

	end


	describe "stringifying" do

		it "works for the ID of an empty repo" do
			id = repo.id

			expect( id.to_s ).to eq( '0000000000000000000000000000000000000000 tip' )
		end


		it "works for the ID of a repo with uncommitted changes" do
			newfile = repo_dir + 'README.md'
			newfile.write( <<~END_OF_FILE )
			So much less to see here.
			END_OF_FILE

			repo.add

			id = repo.id

			expect( id.to_s ).to match( /\A\p{XDigit}{40}\+ tip/ )
		end


		it "works for the ID of a repo with more than one tag" do
			newfile = repo_dir + 'README.md'
			newfile.write( "A file." )

			repo.add
			repo.commit( message: "Added a README" )
			repo.tag( "v1", "add_readme", "live" )
			repo.update( rev: '-2' )

			id = repo.id

			expect( id.to_s ).to match( %r(\A\p{XDigit}{40} add_readme/live/v1) )
		end


		it "works for the ID of a repo with a bookmark" do
			newfile = repo_dir + 'README.md'
			newfile.write( "A file." )

			repo.add
			repo.commit( message: "Added a README" )
			repo.bookmark( "master" )

			id = repo.id

			expect( id.to_s ).to match( %r(\A\p{XDigit}{40} tip master) )
		end

	end

end

