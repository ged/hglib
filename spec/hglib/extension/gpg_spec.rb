#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'hglib/extension/gpg'


RSpec.describe Hglib::Extension::GPG do

	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end

	let( :server ) { instance_double(Hglib::Server) }

	let( :repo ) { Hglib::Repo.new( repo_dir ) }

	before( :each ) do
		allow( Hglib::Server ).to receive( :new ).and_return( server )
	end



	it "can sign a revision" do
		expect( server ).to receive( :run ).
			with( :sign, nil, any_args ).
			and_return( "signing 2:2b937981802a\n" )

		expect( repo.sign ).to eq( "signing 2:2b937981802a" )
	end

end

