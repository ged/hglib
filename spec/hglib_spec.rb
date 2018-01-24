#!/usr/bin/env rspec -cfd

require_relative 'spec_helper'

require 'hglib'


describe Hglib do

	before( :each ) do
		@real_hg_path = described_class.hg_path
	end

	after( :each ) do
		described_class.hg_path = @real_hg_path
	end


	it "has a default hg binary path" do
		expect( described_class::DEFAULT_HG_PATH ).to be_a( Pathname )
		expect( described_class::DEFAULT_HG_PATH.to_s ).to end_with( '/hg' )
	end


	it "can be configured to use a different hg binary" do
		expect {
			described_class.hg_path = '/somewhere/else/hg'
		}.to change { described_class.hg_path }
	end

end

