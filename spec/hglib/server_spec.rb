#!/usr/bin/env rspec -cfd

require_relative '../spec_helper'

require 'tmpdir'
require 'hglib/server'


RSpec.describe Hglib::Server do

	def cmdserver_message( channel, data='' )
		return [ channel, data.bytesize, data ].pack( 'A*I>A*' )
	end

	def cmdserver_header( channel, bytes )
		return [ channel, bytes ].pack( 'aI>' )
	end


	let( :repo_dir ) do
		Dir.mktmpdir( ['hglib', 'repodir'] )
	end

	let( :parent_reader ) { StringIO.new }
	let( :child_reader ) { instance_double(IO, close: true) }
	let( :parent_writer ) { StringIO.new }
	let( :child_writer ) { instance_double(IO, close: true) }

	let( :hello_message ) do
		cmdserver_message( 'o', "capabilities: runcommand getencoding\nencoding: UTF-8\n" )
	end
	let( :line_input_prompt ) do
		cmdserver_header( 'L', 4096 )
	end
	let( :byte_input_prompt ) do
		cmdserver_header( 'I', 4096 )
	end
	let( :result_message ) do
		cmdserver_message( 'r', "done" )
	end


	before( :each ) do
		allow( Process ).to receive( :spawn ).and_return( 1111 )
		allow( Process ).to receive( :kill ).with( :TERM, 1111 )
		allow( Process ).to receive( :wait ).with( 1111, Process::WNOHANG )

		allow( IO ).to receive( :pipe ).and_return(
			[parent_reader, child_writer],
			[child_reader, parent_writer]
		)
	end


	describe "option-mangling" do

		it "mangles single-letter keys into one-hyphen options" do
			result = described_class.mangle_options( C: true, p: true, g: true )
			expect( result ).to eq( %w[-C -p -g] )
		end


		it "mangles multi-letter keys into two-hyphen options" do
			result = described_class.mangle_options( copies: true, patch: true )
			expect( result ).to eq( %w[--copies --patch] )
		end


		it "drops single-letter keys with falsey values" do
			result = described_class.mangle_options( g: false, p: nil )
			expect( result ).to eq( [] )
		end


		it "negates multi-letter keys with falsey values" do
			result = described_class.mangle_options( graph: false, patch: nil )
			expect( result ).to eq( %w[--no-graph --no-patch] )
		end


		it "appends String values onto options with a space for single-letter keys" do
			result = described_class.mangle_options( P: '165' )
			expect( result ).to eq( %w[-P 165] )
		end


		it "appends String values onto options with an equal for multi-letter keys" do
			result = described_class.mangle_options( prune: '165' )
			expect( result ).to eq( %w[--prune=165] )
		end

	end


	it "knows whether or not it has been started" do
		parent_reader.write( hello_message )
		parent_reader.rewind

		server = described_class.new( repo_dir )

		expect( server ).to_not be_started
		server.start
		expect( server ).to be_started
	end


	it "calls the on_line_input callback when the command server asks for line input" do
		parent_reader.write( hello_message )
		parent_reader.write( line_input_prompt )
		parent_reader.write( result_message )
		parent_reader.rewind

		server = described_class.new( repo_dir )
		server.on_line_input do |max_bytes|
			"a line of input no more than #{max_bytes} long"
		end
		server.run( :record )

		expect( parent_writer.string ).to include(
			"runcommand\n",
			"record",
			"a line of input no more than 4096 long\n"
		)
	end


	it "calls the on_byte_input callback when the command server asks for byte input" do
		parent_reader.write( hello_message )
		parent_reader.write( byte_input_prompt )
		parent_reader.write( result_message )
		parent_reader.rewind

		server = described_class.new( repo_dir )
		server.on_byte_input do |max_bytes|
			"bytes of input no more than #{max_bytes} long"
		end
		server.run( :import, '-' )

		expect( parent_writer.string ).to include(
			"runcommand\n",
			"import\0-",
			"bytes of input no more than 4096 long"
		)
	end


	it "can be stopped manually" do
		parent_reader.write( hello_message )
		parent_reader.rewind

		server = described_class.new( repo_dir )
		server.start

		server.stop
		expect( parent_writer.string ).to be_empty
	end


	it "doesn't error when told to stop if it hasn't been started" do
		server = described_class.new( repo_dir )
		expect( server.stop ).to be_falsey
	end


end

