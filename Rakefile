#!/usr/bin/env ruby -S rake

require 'rake/deveiate'

# Dogfood
$LOAD_PATH.unshift( 'lib', '../rake-deveiate/lib' )

Rake::DevEiate.setup( 'hglib' ) do |project|
	project.publish_to = 'deveiate:/usr/local/www/public/code'
	project.required_ruby_version = '~> 2.5'
end


