# -*- ruby -*-
# frozen_string_literal: true

require 'hglib' unless defined?( Hglib )


# Version information methods for Repos and the top-level module.
module Hglib::VersionInfo

	### Fetch a Hash of version information about the Mercurial that is being used.
	def versions
		response = self.server.run_with_json_template( :version )
		return response.first
	end


	### Fetch the version of Mercurial that's being used as a String.
	def version
		return self.versions[ :ver ]
	end


	### Fetch the version of the Mercurial extensions that're being used as a Hash.
	def extension_versions
		ext_info = self.versions[ :extensions ]
		return ext_info.each_with_object({}) do |ext, hash|
			ext = ext.dup
			hash[ ext.delete(:name).to_sym ] = ext
		end
	end


	### Returns +true+ if the extension with the given +name+ is enabled in the
	### current (global) configuration.
	def extension_enabled?( name )
		return self.extension_versions.key?( name.to_sym )
	end

end # module Hglib::VersionInfo

