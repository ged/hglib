#!/usr/bin/ruby -*- ruby -*-

$LOAD_PATH.unshift( File.expand_path 'lib' )

begin
	require 'hglib'
	require 'loggability'
rescue Exception => e
	$stderr.puts "Ack! Libraries failed to load: #{e.message}\n\t" +
		e.backtrace.join( "\n\t" )
end


Loggability.level = :debug
