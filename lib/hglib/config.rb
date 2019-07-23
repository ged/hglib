# -*- ruby -*-
# frozen_string_literal: true

require 'loggability'
require 'hglib' unless defined?( Hglib )


class Hglib::Config
	extend Loggability
	include Enumerable


	# Config item type
	Item = Struct.new( :value, :source )


	# Log to the Hglib logger
	log_to :hglib


	### Create a new Config object from the given +config_items+.
	def initialize( *config_items )
		@items = self.expand_config_items( config_items )
	end


	######
	public
	######

	##
	# The Hash of Hglib::Config::Items from the config, keyed by name.
	attr_reader :items


	### Fetch the value of the config item +key+.
	def []( key )
		return self.items[ key ]&.value
	end


	### Call the block once for each config item, yielding the key and the Item.
	def each( &block )
		return self.items.each( &block )
	end


	### Expand the Array of configuration +items+ such as that returned by the JSON
	### template of `hg showconfig` and return a hierarchical Hash.
	def expand_config_items( items )
		return items.flatten.each_with_object( {} ) do |item, hash|
			self.log.debug "Expanding %p" % [ item ]
			hash[ item[:name] ] = Item.new( item[:value], item[:source] )
		end
	end


end # class Hglib::Config


