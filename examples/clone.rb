#!/usr/bin/env ruby

require 'loggability'
require 'hglib'

Loggability.level = :debug

Dir.chdir( File.expand_path('~/temp/') ) do
	repo = Hglib.clone( 'https://hg.sr.ht/~ged/hglib' )
	puts repo.status
end


