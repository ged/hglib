# -*- ruby -*-
# frozen_string_literal: true

require 'hglib/extension' unless defined?( Hglib::Extension )


module Hglib::Extension::GPG
	extend Hglib::Extension


	repo_commands do

		### Sign the given +rev+ (or the current one if not specified).
		def sign( rev=nil, **options )
			response = self.server.run( :sign, rev, **options )
			return response.chomp
		end


		### Check the signature of the given +rev+.
		def sigcheck( rev, **options )
			response = self.server.run( :sigcheck, rev, **options )
			return response.chomp
		end


		### Return an Array describing all of the signed changesets.
		def sigs( **options )
			response = self.server.run( :sigs, **options )
			return response.lines.map( &:chomp )
		end

	end

end # module Hglib::Extension::GPG

