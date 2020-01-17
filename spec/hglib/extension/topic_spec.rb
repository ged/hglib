#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'hglib/extension/topic'


RSpec.describe Hglib::Extension::Topic do

	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end

	let( :server ) { instance_double(Hglib::Server) }
	let( :repo ) { Hglib::Repo.new( repo_dir ) }


	before( :each ) do
		allow( Hglib::Server ).to receive( :new ).and_return( server )
	end


	let( :topics_data ) {[
		{
			active: true,  lasttouched: "5 days ago", usertouched: "Michael Granger",
			changesetcount: 16, topic: "add-async-subsystem"
		},
		{
			active: false, lasttouched: "6 weeks ago", usertouched: "Michael Granger",
			changesetcount:  3, topic: "basic-setup"
		},
		{
			active: false, lasttouched: "6 weeks ago", usertouched: "Michael Granger",
			changesetcount:  1, topic: "hook-options"
		},
		{
			active: false, lasttouched: "5 months ago", usertouched: "J. Random Hacker",
			changesetcount:  1, topic: "trailblazer"
		},
		{
			active: false, lasttouched: "11 months ago", usertouched: "Michael Granger",
			changesetcount: 31, topic: "web-interface"
		},
	]}

	let( :topic_changesets ) {[
		{
			desc: "Update the API docs", isentry: true,
			node: "0041a0503a0f0d0857c5da8bdcc9a736c1da54df", stack_index: 2,
			state: ["current"], symbol: "@"
		},
		{
			desc: "Modernize RSpec setup", isentry: true,
			node: "e3e847119c6a9865cca8fbf3a0ca377fcdd1cb05", stack_index: 1,
			state: ["clean"], symbol: ":"
		},
		{
			desc: "Add messaging, more async subsystem", isentry: false,
			node: "9ffdbdfb14a928e2e2d41c4a971b88dcb44c67df", stack_index: 0,
			state: ["base"], symbol: "^"
		}
	]}


	it "can fetch a list of topics" do
		expect( server ).to receive( :run_with_json_template ).
			with( :topics, nil, {age: true, verbose: true} ).
			and_return( topics_data )

		results = repo.topics

		expect( results ).to be_an( Array ).and( all be_a(Hglib::Extension::Topic::Entry) )

		expect( results[0] ).to have_attributes(
			name: 'add-async-subsystem', changeset_count: 16,
			last_touched: "5 days ago", user_touched: "Michael Granger"
		)
		expect( results[0] ).to be_active

		expect( results[1] ).to have_attributes(
			name: 'basic-setup', changeset_count: 3,
			last_touched: "6 weeks ago", user_touched: "Michael Granger"
		)
		expect( results[1] ).not_to be_active

		expect( results[2] ).to have_attributes(
			name: 'hook-options', changeset_count: 1,
			last_touched: "6 weeks ago", user_touched: "Michael Granger"
		)
		expect( results[2] ).not_to be_active

		expect( results[3] ).to have_attributes(
			name: 'trailblazer', changeset_count: 1,
			last_touched: "5 months ago", user_touched: "J. Random Hacker"
		)
		expect( results[3] ).not_to be_active

		expect( results[4] ).to have_attributes(
			name: 'web-interface', changeset_count: 31,
			last_touched: "11 months ago", user_touched: "Michael Granger"
		)
		expect( results[4] ).not_to be_active
	end


	it "prevents the :list flag from being used" do
		expect {
			repo.topics( list: true )
		}.to raise_error( ArgumentError, /implemented with the #stack method/i )
	end


	it "can fetch the name of the current topic" do
		expect( server ).to receive( :run ).
			with( :topics, nil, {current: true} ).
			and_return( "add-async-subsystem\n" )

		expect( repo.topic ).to eq( 'add-async-subsystem' )
	end


	it "returns nil for the topic if there is no active topic" do
		expect( server ).to receive( :run ).
			with( :topics, nil, {current: true} ).
			and_raise( Hglib::CommandError.new(:topics, ["no active topic\n"]) )

		expect( repo.topic ).to be_nil
	end


	it "can return the stack of changesets from the current topic" do
		expect( server ).to receive( :run_with_json_template ).
			with( :stack, nil, any_args ).
			and_return( topic_changesets )

		results = repo.stack

		expect( results ).to be_an( Array ).and( all be_a(Hglib::Extension::Topic::StackEntry) )

		expect( results[0] ).to have_attributes(
			desc: "Update the API docs",
			node: "0041a0503a0f0d0857c5da8bdcc9a736c1da54df",
			stack_index: 2,
			state: ["current"],
			symbol: "@"
		)
		expect( results[0] ).to be_an_entry

		expect( results[1] ).to have_attributes(
			desc: "Modernize RSpec setup",
			node: "e3e847119c6a9865cca8fbf3a0ca377fcdd1cb05",
			stack_index: 1,
			state: ["clean"],
			symbol: ":"
		)
		expect( results[1] ).to be_an_entry

		expect( results[2] ).to have_attributes(
			desc: "Add messaging, more async subsystem",
			node: "9ffdbdfb14a928e2e2d41c4a971b88dcb44c67df",
			stack_index: 0,
			state: ["base"],
			symbol: "^"
		)
		expect( results[2] ).not_to be_an_entry
	end

end

