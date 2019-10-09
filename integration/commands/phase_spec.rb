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


	before( :each ) do
		@file_counter = 0
	end

	after( :each ) do
		repo_dir.rmtree if repo_dir.exist?
	end


	### Add +count+ files to the repo.
	def add_files( count=rand(1..5) )
		return count.times.map do
			filename = "file-%03d" % [ @file_counter ]
			file_path = repo_dir + filename

			Loggability[ Hglib ].debug "Writing %s" % [ file_path ]
			file_path.write( SecureRandom.base64(128) )

			@file_counter += 1
			file_path
		end
	end


	### Make a commit in the 
	def make_a_commit
		files = add_files()

		repo.add
		repo.commit( message: "Creating a commit with %d files" % [ files.length ] )
	end


	it "can change the phase of the current revision" do
		5.times { make_a_commit() }

		phases = repo.phase( '4:0' )

		expect( phases ).to eq( {4 => :draft, 3 => :draft, 2 => :draft, 1 => :draft, 0 => :draft} )
	end
end

