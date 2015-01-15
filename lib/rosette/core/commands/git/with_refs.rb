# encoding: UTF-8

require 'thread'

module Rosette
  module Core
    module Commands

      # Mixin that handles configuration and validation of a set of git refs or
      # commit ids. Meant to be mixed into the classes in {Rosette::Core::Commands}.
      # Required to be used in combination with {Rosette::Core::Commands::WithRepoName}.
      #
      # @see Rosette::Core::Commands::WithRepoName
      #
      # @example
      #   class MyCommand < Rosette::Core::Commands::Command
      #     include WithRepoName
      #     include WithRefs
      #   end
      #
      #   cmd = MyCommand.new
      #     .set_repo_name('my_repo')
      #     .set_refs(['master'])
      #
      #   cmd.commit_strs  # => ["master"]
      #   cmd.commit_ids   # => ["67f0e9a60dfe39430b346086f965e6c94a8ddd24"]
      #   cmd.valid?         # => true
      #
      #   cmd.set_refs(['non_existent_ref'])
      #   cmd.valid?    # => false
      #   cmd.messages  # => { commit_str: ["Unable to find commit 'non_existent_ref'"] }
      #
      # @!attribute [r] commit_str
      #   @return [String] the raw value as set by either {#set_ref} or {#set_commit_id}.
      module WithRefs
        attr_reader :commit_strs

        # Set the git refs (i.e. a branch names). Calling this method after {#set_commit_ids}
        # will overwrite the commit id values. In other words, it's generally a good idea to
        # only call one of {#set_commit_ids} or {#set_refs} but not both.
        #
        # @param [Array<String>] ref_strs The git refs.
        # @return [self]
        def set_refs(ref_strs)
          @commit_strs = ref_strs
          self
        end

        # Set the git commit ids. Calling this method after {#set_refs} will overwrite the ref values.
        # In other words, it's generally a good idea to only call one of {#set_commit_ids} or {#set_refs}
        # but not both.
        #
        # @param [Array<String>] commit_ids The commit ids.
        # @return [self]
        def set_commit_ids(commit_ids)
          @commit_strs = commit_ids
          self
        end

        # Resolves the git ref or commit id at +index+ and returns the corresponding commit id.
        # If {#set_refs} was used to set git refs (i.e. branch names), this method looks up
        # and returns the corresponding commit id. If {#set_commit_ids} was used to set
        # commit ids, then that commit id is validated and returned.
        #
        # @param [Fixnum] index The index of the ref or commit id to return.
        # @return [String] The commit id set via either {#set_refs} or {#set_commit_ids}.
        # @raise [Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException]
        #   If either the commit id doesn't exist or the ref can't be found.
        def commit_ids
          @commit_ids ||= @commit_strs.map do |commit_str|
            REV_COMMIT_MUTEX.synchronize do
              get_repo(repo_name)
                .repo.get_rev_commit(commit_str)
                .getId.name
            end
          end
        end

        private

        REV_COMMIT_MUTEX = Mutex.new

        def self.included(base)
          if base.respond_to?(:validate)
            base.validate :commit_strs, type: :commits
          end
        end
      end

    end
  end
end
