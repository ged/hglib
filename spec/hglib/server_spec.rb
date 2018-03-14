#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'tmpdir'
require 'hglib/server'


RSpec.describe Hglib::Server do

	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end


	it "knows whether or not it has been started" do
		server = described_class.new( repo_dir )

		expect( server ).to_not be_started
		server.start
		expect( server ).to be_started
	end


	

end

