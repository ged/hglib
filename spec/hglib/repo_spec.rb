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


	it "returns an empty Array if the working directory is clean" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :status, {} ).
			and_return( [] )

		result = repo.status

		expect( result ).to be_an( Array ).and be_empty
	end


	it "can fetch the status of the working directory" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :status, {} ).
			and_return([
				{
					path: "lib/hglib/repo.rb",
					status: "!"
				},
				{
					path: "a_new_file.txt",
					status: "?"
				},
				{
					path: "doc/created.rid",
					status: "?"
				},
				{
					path: "lib/hglib/bepo.rb",
					status: "?"
				}
			])

		result = repo.status

		expect( result ).to be_an( Array )
		expect( result ).to all( be_a Hglib::Repo::StatusEntry )
		expect( result.map(&:path) ).to include(
			Pathname('lib/hglib/repo.rb'),
			Pathname('a_new_file.txt'),
			Pathname('doc/created.rid'),
			Pathname('lib/hglib/bepo.rb'),
		)
	end


	it "can fetch the identification of the repository's current revision" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :identify, nil, {} ).
			and_return( [{
				bookmarks: ["v1.1", "live", "master"],
				branch: "default",
				dirty: "+",
				id: "720c115412188539039b87baf57931fb5415a0bf+",
				node: "ffffffffffffffffffffffffffffffffffffffff",
				parents: ["720c115412188539039b87baf57931fb5415a0bf"],
				tags: ["tip"]
			}] )

		result = repo.id

		expect( result ).to be_a( Hglib::Repo::Id ).and( eq '720c115412188539039b87baf57931fb5415a0bf' )
		expect( result.tags ).to eq( %w[tip] )
		expect( result.bookmarks ).to eq( %w[v1.1 live master] )
	end


	it "can fetch the log of the repository" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :log, {graph: false} ).
			and_return([
				{
					bookmarks: [],
					branch: "default",
					date: [1516812073, 28800],
					desc: "Make ruby-version less specific",
					node: "81f357f730d9f22d560e4bd2790e7cf5aa5b7ec7",
					parents: ["d6c97f99b012199d9088e85bb0940147446c6a87"],
					phase: "public",
					rev: 1,
					tags: [],
					user: "Michael Granger <ged@FaerieMUD.org>"
				},
				{
					bookmarks: [],
					branch: "default",
					date: [1516811121, 28800],
					desc: "Initial commit.",
					node: "d6c97f99b012199d9088e85bb0940147446c6a87",
					parents: ["0000000000000000000000000000000000000000"],
					phase: "public",
					rev: 0,
					tags: [],
					user: "Michael Granger <ged@FaerieMUD.org>"
				}
			])

		result = repo.log

		expect( result ).to be_an( Array ).and( all be_a(Hglib::Repo::LogEntry) )
	end


	it "can fetch a diff of the current working copy of the repository" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :diff, {} ).
			and_return( "the diff" )

		result = repo.diff

		expect( result ).to eq( "the diff" )
	end


	it "can fetch a diff of particular files" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :diff, 'README.md', 'Rakefile', {} ).
			and_return( "two files diff" )

		result = repo.diff( 'README.md', 'Rakefile' )

		expect( result ).to eq( "two files diff" )
	end


	it "can return the current Mercurial configuration" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :showconfig, {untrusted: false} ).
			and_return([
				{
					name: "progress.delay",
					source: "/home/jrandom/.hgrc:96",
					value: "0.1"
				},
				{
					name: "progress.refresh",
					source: "/home/jrandom/.hgrc:97",
					value: "0.1"
				},
				{
					name: "progress.format",
					source: "/home/jrandom/.hgrc:98",
					value: "topic bar number"
				},
				{
					name: "progress.clear-complete",
					source: "/home/jrandom/.hgrc:99",
					value: "True"
				}
			])

		result = repo.config

		expect( result ).to be_a( Hglib::Config )
		expect( result['progress.delay'] ).to eq( '0.1' )
		expect( result['progress.format'] ).to eq( 'topic bar number' )
	end


	it "can fetch repo aliases" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run_with_json_template ).
			with( :paths ).
			and_return([
				{name: 'sourcehut', url: 'ssh://hg@hg.sr.ht/~ged/hglib'},
				{name: 'default', url: 'ssh://hg@deveiate.org/hglib'},
				{name: 'github', url: 'git+ssh://git@github.com/ged/hglib.git'}
			])

		result = repo.paths

		expect( result ).to be_a( Hash )
		expect( result ).to eq(
			sourcehut: URI('ssh://hg@hg.sr.ht/~ged/hglib'),
			default: URI('ssh://hg@deveiate.org/hglib'),
			github: URI('git+ssh://git@github.com/ged/hglib.git')
		)
	end


	it "can add all new files to the repository" do
		repo = described_class.new( repo_dir )

		expect( server ).to receive( :run ).with( :add, {} )

		result = repo.add
		expect( result ).to be_truthy
	end

end

