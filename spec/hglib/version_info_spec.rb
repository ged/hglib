#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'loggability'
require 'hglib/version_info'


RSpec.describe Hglib::VersionInfo do

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

	let( :including_class ) do
		cls = Class.new do
			extend Loggability
			log_to :hglib
			def initialize( server )
				@server = server
			end
			attr_reader :server
		end
		cls.include( described_class )
		cls
	end

	let( :server ) { instance_double(Hglib::Server, stop: nil) }

	let( :extended_object ) { including_class.new(server) }

	before( :each ) do
		expect( server ).to receive( :run_with_json_template ).
			with( :version ).
			and_return( version_info ).
			at_least( :once )
	end


	it "can fetch the versions of Mercurial and loaded extensions" do
		result = extended_object.versions

		expect( result ).to eq( version_info.first )
	end


	it "can fetch the simple version of Mercurial" do
		result = extended_object.version

		expect( result ).to eq( version_info.first[:ver] )
	end


	it "can fetch the versions of all loaded Mercurial extensions" do
		result = extended_object.extension_versions

		expect( result ).to be_a( Hash )
		expect( result ).to include(
			churn: {bundled: true, ver: nil},
			evolve: {bundled: false, ver: '9.2.0'},
			topic: {bundled: false, ver: '0.17.0'},
			hggit: {bundled: false, ver: "0.8.12 (dulwich 0.19.10)"}
		)
	end


	it "knows if a given extension is enabled" do
		expect( extended_object.extension_enabled?('topic') ).to be_truthy
		expect( extended_object.extension_enabled?('keyword') ).to be_falsey
	end

end

