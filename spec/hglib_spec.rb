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

		it "can create a server object with no repository" do
			expect( described_class.server ).to be_a( Hglib::Server )
			expect( described_class.server ).to equal( described_class.server )
			expect( described_class.server.repo ).to be_nil
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



	describe "version info" do

		let( :version_info ) {[{
			extensions: [
				{bundled: true,  name: "churn",    ver: nil},
				{bundled: true,  name: "convert",  ver: nil},
				{bundled: false, name: "evolve",   ver: "9.2.0"},
				{bundled: true,  name: "extdiff",  ver: nil},
				{bundled: true,  name: "gpg",      ver: nil},
				{bundled: false, name: "hggit",    ver: "0.8.12 (dulwich 0.19.10)"},
				{bundled: true,  name: "strip",    ver: nil},
				{bundled: true,  name: "mq",       ver: nil},
				{bundled: false, name: "prompt",   ver: nil},
				{bundled: true,  name: "purge",    ver: nil},
				{bundled: true,  name: "rebase",   ver: nil},
				{bundled: false, name: "topic",    ver: "0.17.0"},
				{bundled: true,  name: "histedit", ver: nil}
			],
			ver: "5.1.1"
		}]}

		let( :server ) { instance_double(Hglib::Server, stop: nil) }


		before( :each ) do
			described_class.reset_server
			allow( Hglib::Server ).to receive( :new ).and_return( server )
			expect( server ).to receive( :run_with_json_template ).
				with( :version ).
				and_return( version_info ).
				at_least( :once )
		end
		after( :each ) do
			described_class.reset_server
		end


		it "can fetch the versions of Mercurial and loaded extensions" do
			result = described_class.versions

			expect( result ).to eq( version_info.first )
		end


		it "can fetch the simple version of Mercurial" do
			result = described_class.version

			expect( result ).to eq( version_info.first[:ver] )
		end


		it "can fetch the versions of all loaded Mercurial extensions" do
			result = described_class.extension_versions

			expect( result ).to be_a( Hash )
			expect( result ).to include(
				churn: {bundled: true, ver: nil},
				evolve: {bundled: false, ver: '9.2.0'},
				topic: {bundled: false, ver: '0.17.0'},
				hggit: {bundled: false, ver: "0.8.12 (dulwich 0.19.10)"}
			)
		end


		it "knows if a given extension is enabled" do
			expect( described_class.extension_enabled?('topic') ).to be_truthy
			expect( described_class.extension_enabled?('keyword') ).to be_falsey
		end

	end

end

