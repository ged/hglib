# -*- ruby -*-
# frozen_string_literal: true

require 'hglib' unless defined?( Hglib )


module Hglib

	# A collection of methods for declaring other methods.
	#
	#   class MyClass
	#       extend Hglib::MethodUtilities
	#
	#       singleton_attr_accessor :types
	#       singleton_method_alias :kinds, :types
	#   end
	#
	#   MyClass.types = [ :pheno, :proto, :stereo ]
	#   MyClass.kinds # => [:pheno, :proto, :stereo]
	#
	module MethodUtilities

		### Creates instance variables and corresponding methods that return their
		### values for each of the specified +symbols+ in the singleton of the
		### declaring object (e.g., class instance variables and methods if declared
		### in a Class).
		def singleton_attr_reader( *symbols )
			symbols.each do |sym|
				singleton_class.__send__( :attr_reader, sym )
			end
		end

		### Creates methods that allow assignment to the attributes of the singleton
		### of the declaring object that correspond to the specified +symbols+.
		def singleton_attr_writer( *symbols )
			symbols.each do |sym|
				singleton_class.__send__( :attr_writer, sym )
			end
		end

		### Creates readers and writers that allow assignment to the attributes of
		### the singleton of the declaring object that correspond to the specified
		### +symbols+.
		def singleton_attr_accessor( *symbols )
			symbols.each do |sym|
				singleton_class.__send__( :attr_accessor, sym )
			end
		end

		### Creates an alias for the +original+ method named +newname+.
		def singleton_method_alias( newname, original )
			singleton_class.__send__( :alias_method, newname, original )
		end


		### Create a reader in the form of a predicate for the given +attrname+.
		def attr_predicate( attrname )
			attrname = attrname.to_s.chomp( '?' )
			define_method( "#{attrname}?" ) do
				ivar = "@#{attrname}"
				instance_variable_defined?( ivar ) && instance_variable_get( ivar ) ?
					true :
					false
			end
		end


		### Create a reader in the form of a predicate for the given +attrname+
		### as well as a regular writer method.
		def attr_predicate_accessor( attrname )
			attrname = attrname.to_s.chomp( '?' )
			attr_writer( attrname )
			attr_predicate( attrname )
		end

	end # module MethodUtilities


	# An extensible #inspect for Hglib objects.
	module Inspection

		### Return a human-readable representation of the object suitable for debugging.
		def inspect
			return "#<%p:%#016x %s>" % [
				self.class,
				self.object_id * 2,
				self.inspect_details,
			]
		end


		### Return the detail portion of the inspect output for this object.
		def inspect_details
			return self.instance_variables.sort.map do |ivar|
				"%s=%p" % [ ivar, self.instance_variable_get(ivar) ]
			end.join( ', ' )
		end

	end # module Inspection




end # module Hglib

