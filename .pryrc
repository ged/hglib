#!/usr/bin/ruby -*- ruby -*-

$LOAD_PATH.unshift( File.expand_path 'lib' )

require 'loggability'

Loggability.level = :debug
Loggability.format_with( :color )

require 'hglib'

