# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'hglib' unless defined?( Hglib )


class Hglib::Config
	extend Loggability

	# Log to the Hglib logger
	log_to :hglib


	Item = Struct.new( :value, :source )


	### Create a new Config object from the given +config_items+.
	def initialize( *config_items )
		@items = self.expand_config_items( config_items )
	end

	{
		:name=>"merge-tools.araxis.priority",
		:source=>"/usr/local/Cellar/mercurial/5.0/lib/python2.7/site-packages/mercurial/default.d/mergetools.rc:127",
		:value=>"-2"
	},
	{
		:name=>"merge-tools.araxis.args",
		:source=>"/usr/local/Cellar/mercurial/5.0/lib/python2.7/site-packages/mercurial/default.d/mergetools.rc:128",
		:value=>"/3 /a2 /wait /merge /title1:\"Other\" /title2:\"Base\" /title3:\"Local :\"$local $other $base $local $output"
	},


	### Expand the Array of configuration +items+ such as that returned by the JSON
	### template of `hg showconfig` and return a hierarchical Hash.
	def expand_config_items( items )
		return items.each_with_object( {} ) do |item, hash|
			hash[ item[:name] ] = Item.new( *item.values_at(:value, :source) )
			
		end
	end


end # class Hglib::Config


