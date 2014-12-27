# encoding: UTF-8

require 'thread'

module Rosette
  module Core
    module Commands

      # Mixin that handles configuration and validation of a git ref or commit id.
      # Meant to be mixed into the classes in {Rosette::Core::Commands}. Required
      # to be used in combination with {Rosette::Core::Commands::WithRepoName}.
      #
      # @see Rosette::Core::Commands::WithNonMergeRef
      # @see Rosette::Core::Commands::WithRepoName
      #
      # @example
      #   class MyCommand < Rosette::Core::Commands::Command
      #     include WithRepoName
      #     include WithRef
      #   end
      #
      #   cmd = MyCommand.new
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #
      #   cmd.commit_str  # => "master"
      #   cmd.commit_id   # => "67f0e9a60dfe39430b346086f965e6c94a8ddd24"
      #   cmd.valid?      # => true
      #
      #   cmd.set_ref('non_existant_ref')
      #   cmd.valid?    # => false
      #   cmd.messages  # => { commit_str: ["Unable to find commit 'non_existent_ref'"] }
      #
      # @!attribute [r] commit_str
      #   @return [String] the raw value as set by either {#set_ref} or {#set_commit_id}.
      module WithRef
        attr_reader :commit_str

        # Set the git ref (i.e. a branch name). Calling this method after {#set_commit_id}
        # will overwrite the commit id value. In other words, it's generally a good idea to
        # only call one of {#set_commit_id} or {#set_ref} but not both.
        #
        # @param [String] ref_str The git ref.
        # @return [self]
        def set_ref(ref_str)
          @commit_str = ref_str
          self
        end

        # Set the git commit id. Calling this method after {#set_ref} will overwrite the ref value.
        # In other words, it's generally a good idea to only call one of {#set_commit_id} or {#set_ref}
        # but not both.
        #
        # @param [String] commit_id The commit id.
        # @return [self]
        def set_commit_id(commit_id)
          @commit_str = commit_id
          self
        end

        # Resolves the given git ref or commit id and returns the corresponding commit id.
        # If {#set_ref} was used to set a git ref (i.e. branch name), this method looks up
        # and returns the corresponding commit id. If {#set_commit_id} was used to set a
        # commit id, then that commit id is validated and returned.
        #
        # @return [String] The commit id set via either {#set_ref} or {#set_commit_id}.
        # @raise [Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException]
        #   If either the commit id doesn't exist or the ref can't be found.
        def commit_id
          @commit_id ||= begin
            REV_COMMIT_MUTEX.synchronize do
              get_repo(repo_name)
                .repo.get_rev_commit(@commit_str)
                .getId.name
            end
          end
        end

        private

        REV_COMMIT_MUTEX = Mutex.new

        def self.included(base)
          if base.respond_to?(:validate)
            base.validate :commit_str, type: :commit
          end
        end
      end

    end
  end
end
