# -*- ruby -*-
# frozen_string_literal: true

require 'hglib/extension' unless defined?( Hglib::Extension )
require 'hglib/mixins'


# Extension module for the Mercurial `topic` extension
module Hglib::Extension::Topic
	extend Hglib::Extension


	# A topic in an Hglib::Repo.
	class Entry
		extend Hglib::MethodUtilities
		include Hglib::Inspection

		### Create a new Entry for the specified +repo+ given an +entryhash+ like that
		### returned by the JSON template for the `topics` command.
		def initialize( repo, entryhash )
			@repo = repo

			@name            = entryhash[:topic]
			@active          = entryhash[:active]
			@changeset_count = entryhash[:changesetcount]
			@branch          = entryhash[:"branches+"]
			@last_touched    = entryhash[:lasttouched]
			@user_touched    = entryhash[:usertouched]
		end


		######
		public
		######

		##
		# The Hglib::Repo of the repository the topic belongs to
		attr_reader :repo

		##
		# The name of the topic
		attr_reader :name

		##
		# The name of the branch the topic is on
		attr_reader :branch

		##
		# Whether or not the entry is current active
		attr_predicate :active

		##
		# The number of changesets belonging to the topic
		attr_reader :changeset_count
		alias_method :changesetcount, :changeset_count

		##
		# The human description of when the topic last had changesets added to it
		# (if it was fetched)
		attr_reader :last_touched
		alias_method :lasttouched, :last_touched

		##
		# The name of the last user to add changesets to the topic (if it was fetched)
		attr_reader :user_touched
		alias_method :usertouched, :user_touched
		alias_method :touched_by, :user_touched


		### Return the entry as a String (in a similar form to the regular `hg topics` output)
		def to_s
			rval = String.new( encoding: 'utf-8' )
			rval << "%s (" % [ self.name ]
			rval << "%s" % [ self.last_touched ] if self.last_touched
			rval << " by %s" % [ self.user_touched ] if self.user_touched
			rval << ', ' if self.last_touched || self.user_touched
			rval << "%d changesets)" % [ self.changeset_count ]
			rval << " [active]" if self.active?
			rval.freeze

			return rval
		end
		alias_method :inspect_details, :to_s


		### Return the changesets that belong to this topic as
		### Hglib::Extension::Topic::StackEntry objects.
		def stack
			return self.repo.stack( self.name )
		end

	end # class Entry


	# A changeset in a topic
	class StackEntry
		extend Hglib::MethodUtilities
		include Hglib::Inspection


		### Create a new StackEntry for the specified +repo+ given an +entryhash+ like that
		### returned by the JSON template for the `topics` command.
		def initialize( repo, entryhash )
			@repo = repo

			@description = entryhash[:desc]
			@is_entry    = entryhash[:isentry]
			@node        = entryhash[:node]
			@stack_index = entryhash[:stack_index]
			@state       = entryhash[:state]
			@symbol      = entryhash[:symbol]
		end


		######
		public
		######

		##
		# The Hglib::Repo of the repository the changeset belongs to
		attr_reader :repo

		##
		# The changeset description
		attr_reader :description
		alias_method :desc, :description

		##
		# True if the changeset is an entry(?)
		# :TODO: Figure out what this means
		attr_predicate :is_entry
		alias_method :entry?, :is_entry?

		##
		# The node identifier of the changeset
		attr_reader :node

		##
		# The index of the changeset in the topic it is currently in
		attr_reader :stack_index

		##
		# An array of states that apply to this changeset(?)
		# :TODO: Figure out what these mean
		attr_reader :state

		##
		# A character that represents the changeset's (state?)
		# :TODO: Figure out what this means
		attr_reader :symbol


		### Return the entry as a String (in a similar form to the regular `hg topics` output)
		def to_s
			displayed_states = self.state - ['clean']

			rval = String.new( encoding: 'utf-8' )
			rval << %{s%d%s "%s"} % [ self.stack_index, self.symbol, self.description ]
			rval << " (%s)" % [ displayed_states.join(', ') ] unless displayed_states.empty?
			rval.freeze

			return rval
		end
		alias_method :inspect_details, :to_s

	end # class StackEntry



	repo_commands do

		### Return an Hglib::Extension::Topic::Entry object for each topic in the
		### repo.
		def topics( **options )
			raise ArgumentError, ":list option is implemented with the #stack method" if
				options[:list]

			options[:age] = true
			options[:verbose] = true
			response = self.server.run_with_json_template( :topics, nil, **options )

			return response.map do |entryhash|
				Hglib::Extension::Topic::Entry.new( self, entryhash )
			end
		end


		### Operate on a topic, either the one with the given +name+ or the current one
		### if +name+ is not given.
		def topic( name=nil, **options )
			options[:current] = true unless name || options[:clear]
			result = self.server.run( :topics, name, **options )
			return result.chomp
		rescue Hglib::CommandError => err
			# Running `topic --current` with no active topic is an error apparently, so
			# if that's the reason for it being raised just return nil instead.
			raise( err ) unless err.message.match?( /no active topic/i )
			return nil
		end


		### Return an Array of all changesets in a topic as
		### Hglib::Extension::Topic::StackEntry objects.
		def stack( topic=nil, **options )
			response = self.server.run_with_json_template( :stack, topic, **options )

			return response.map do |entryhash|
				Hglib::Extension::Topic::StackEntry.new( self, entryhash )
			end
		end

	end

end # module Hglib::Extension::Topic

