#!/usr/bin/env rspec -cfd

require_relative '../../spec_helper'

require 'hglib/repo/id'


RSpec.describe Hglib::Repo::Id do

	it "can be created for an empty repo" do
		result = described_class.new( '000000000000', 'tip' )

		expect( result.global ).to eq( '000000000000' )
		expect( result ).to eq( '000000000000' )
		expect( result.tags ).to contain_exactly( 'tip' )
		expect( result.bookmarks ).to be_empty
		expect( result ).to_not have_uncommitted_changes
	end


	it "can be created for a repo with commits" do
		result = described_class.new( 'd03a659966ec', 'tip' )

		expect( result.global ).to eq( 'd03a659966ec' )
		expect( result ).to eq( 'd03a659966ec' )
		expect( result.tags ).to contain_exactly( 'tip' )
		expect( result.bookmarks ).to be_empty
		expect( result ).to_not have_uncommitted_changes
	end


	it "can be created for a repo with uncommitted changes" do
		result = described_class.new( 'd03a659966ec', 'tip', uncommitted_changes: true )

		expect( result.global ).to eq( 'd03a659966ec' )
		expect( result ).to have_uncommitted_changes
	end


	it "can be created for a repo with more than one tag" do
		result = described_class.new( 'd03a659966ec', 'qbase', 'qtip', 'repo-features.patch', 'tip' )

		expect( result.global ).to eq( 'd03a659966ec' )
		expect( result.tags ).to contain_exactly( 'qbase', 'qtip', 'repo-features.patch', 'tip' )
	end


	it "can be created for a repo with a bookmark" do
		result = described_class.new( 'd03a659966ec', 'tip', bookmarks: 'master' )

		expect( result.global ).to eq( 'd03a659966ec' )
		expect( result.bookmarks ).to contain_exactly( 'master' )
	end


	it "can be created for a repo with more than one bookmark" do
		result = described_class.new( 'd03a659966ec', 'tip', bookmarks: ['master', 'github/master'] )

		expect( result.global ).to eq( 'd03a659966ec' )
		expect( result.bookmarks ).to contain_exactly( 'master', 'github/master' )
	end


	describe "equality" do

		it "is equal to an object of the same class with the same values" do
			id = described_class.new( 'd03a659966ec',
				'qbase', 'qtip', 'repo-features.patch', 'tip',
				uncommitted_changes: true,
				bookmarks: ['master', 'live']
			)

			copy = id.dup

			expect( id ).to eq( copy )
		end


		it "is equal to the String that contains the same revision identifier" do
			id = described_class.new( 'd03a659966ec',
				'qbase', 'qtip', 'repo-features.patch', 'tip',
				uncommitted_changes: true,
				bookmarks: ['master', 'live']
			)

			expect( id ).to eq( 'd03a659966ec' )
		end

	end


	describe "parsing server output" do

		it "can parse the server output from an empty repo" do
			result = described_class.parse( '000000000000 tip' )

			expect( result.global ).to eq( '000000000000' )
			expect( result ).to eq( '000000000000' )
			expect( result.tags ).to contain_exactly( 'tip' )
			expect( result.bookmarks ).to be_empty
			expect( result ).to_not have_uncommitted_changes
		end


		it "can be parsed from the server output from a repo with commits" do
			result = described_class.parse( 'd03a659966ec tip' )

			expect( result.global ).to eq( 'd03a659966ec' )
			expect( result ).to eq( 'd03a659966ec' )
			expect( result.tags ).to contain_exactly( 'tip' )
			expect( result.bookmarks ).to be_empty
			expect( result ).to_not have_uncommitted_changes
		end


		it "can be parsed from the server output from a repo with uncommitted changes" do
			result = described_class.parse( 'd03a659966ec+ tip' )

			expect( result.global ).to eq( 'd03a659966ec' )
			expect( result ).to have_uncommitted_changes
		end


		it "can be parsed from the server output from a repo with more than one tag" do
			result = described_class.parse( 'd03a659966ec qbase/qtip/repo-features.patch/tip' )

			expect( result.global ).to eq( 'd03a659966ec' )
			expect( result.tags ).to contain_exactly( 'qbase', 'qtip', 'repo-features.patch', 'tip' )
		end


		it "can be parsed from the server output from a repo with a bookmark" do
			result = described_class.parse( 'd03a659966ec tip master' )

			expect( result.global ).to eq( 'd03a659966ec' )
			expect( result.bookmarks ).to contain_exactly( 'master' )
		end


		it "can be parsed from the server output from a repo with more than one bookmark" do
			result = described_class.parse( 'd03a659966ec tip master/servant' )

			expect( result.global ).to eq( 'd03a659966ec' )
			expect( result.bookmarks ).to contain_exactly( 'master', 'servant' )
		end

	end


	describe "stringifying" do

		it "works for the ID of an empty repo" do
			id = described_class.new( '000000000000', 'tip' )

			expect( id.to_s ).to eq( '000000000000 tip' )
		end


		it "works for the ID of a repo with uncommitted changes" do
			id = described_class.new( 'd03a659966ec', 'tip', uncommitted_changes: true )

			expect( id.to_s ).to eq( 'd03a659966ec+ tip' )
		end


		it "works for the ID of a repo with more than one tag" do
			id = described_class.new( 'd03a659966ec', 'qbase', 'qtip', 'repo-features.patch', 'tip' )

			expect( id.to_s ).to eq( 'd03a659966ec qbase/qtip/repo-features.patch/tip' )
		end


		it "works for the ID of a repo with a bookmark" do
			id = described_class.new( 'd03a659966ec', 'tip', bookmarks: 'master' )

			expect( id.to_s ).to eq( 'd03a659966ec tip master' )
		end

	end

end

