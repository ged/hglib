#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'hglib'
require 'hglib/extension'
require 'hglib/repo'


RSpec.describe Hglib::Extension do

	it "adds methods to support Mercurial extensions when loaded" do
		described_class.load_all
		expect( Hglib::Repo.instance_methods ).to include( :sign )
	end

end

