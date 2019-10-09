#!/usr/bin/env ruby -S rspec -cfd

require_relative '../spec_helper'

require 'hglib/config'


RSpec.describe Hglib::Config do

	let( :entries ) do
		return [
			{:name=>"progress.delay", :source=>"/Users/ged/.hgrc:96", :value=>"0.1"},
			{:name=>"progress.refresh", :source=>"/Users/ged/.hgrc:97", :value=>"0.1"},
			{:name=>"progress.format", :source=>"/Users/ged/.hgrc:98", :value=>"topic bar number"},
			{:name=>"progress.clear-complete", :source=>"/Users/ged/.hgrc:99", :value=>"True"},
			{:name=>"server.bundle1", :source=>"", :value=>"False"},
			{:name=>"ui.editor", :source=>"$VISUAL", :value=>"emacs"},
			{:name=>"ui.ssh", :source=>"/Users/ged/.hgrc:3", :value=>"ssh -C"},
			{:name=>"ui.ignore", :source=>"/Users/ged/.hgrc:4", :value=>"~/.hgignore_global"},
			{:name=>"ui.merge", :source=>"/Users/ged/.hgrc:5", :value=>"Kaleidoscope"},
			{:name=>"ui.interactive", :source=>"--config", :value=>"True"},
			{:name=>"ui.nontty", :source=>"commandserver", :value=>"true"},
			{:name=>"web.cacerts", :source=>"/Users/ged/.hgrc:122", :value=>""},
		]
	end


	it "expands config items" do
		instance = described_class.new( entries )

		expect( instance['ui.editor'] ).to eq( 'emacs' )
		expect( instance['progress.refresh'] ).to eq( '0.1' )
	end

end

