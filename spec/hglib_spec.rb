#!/usr/bin/env ruby -S rspec -cfd

require_relative 'spec_helper'

require 'hglib'


RSpec.describe Hglib do

	before( :each ) do
		@real_hg_path = described_class.hg_path
	end

	after( :each ) do
		described_class.hg_path = @real_hg_path
	end


	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end


	describe "binary path" do

		it "has a default" do
			expect( described_class::DEFAULT_HG_PATH ).to be_a( Pathname )
			expect( described_class::DEFAULT_HG_PATH.to_s ).to end_with( '/hg' )
		end


		it "can be configured to use a different hg binary" do
			expect {
				described_class.hg_path = '/somewhere/else/hg'
			}.to change { described_class.hg_path }
		end

	end


	describe "server" do

		it "can create a server object" do
			expect( described_class.server ).to be_a( Hglib::Server )
			expect( described_class.server ).to equal( described_class.server )
			expect( described_class.server.repo ).to eq( Pathname('.') )
		end

	end


	describe "repo" do

		it "can create a repo object for the current working directory" do
			result = described_class.repo
			expect( result ).to be_a( Hglib::Repo )
			expect( result.path ).to eq( Pathname('.') )
		end


		it "can create a repo object for a specified directory" do
			result = described_class.repo( repo_dir )
			expect( result ).to be_a( Hglib::Repo )
			expect( result.path ).to eq( Pathname(repo_dir) )
		end


		it "knows a repo dir is a repo dir", :requires_binary do
			described_class.init( repo_dir )
			expect( described_class.is_repo?(repo_dir) ).to be_truthy
		end

	end


	describe "command error" do

		### Rescue any (runtime) exception raised when yielding and return it. If no
		### exception is raised, return nil.
		def rescued
			yield
			return nil
		rescue => err
			return err
		end


		it "can be created with a single error message" do
			exception = rescued {
				raise Hglib::CommandError, [:status, "no_status: No such file or directory\n"]
			}

			expect( exception ).to_not be_multiple
			expect( exception.message ).to eq( "`status`: no_status: No such file or directory" )
		end


		it "can be created with multiple error messages" do
			exception = rescued {
				raise Hglib::CommandError, [
					:status,
					"no_status: No such file or directory\n",
					"unknown: No such file or directory\n"
				]
			}

			expect( exception ).to be_multiple
			expect( exception.message ).to eq( <<~ERROR_MESSAGE )
				`status`:
				  - no_status: No such file or directory
				  - unknown: No such file or directory
			ERROR_MESSAGE
		end

	end

end

