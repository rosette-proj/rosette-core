# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Mixin that handles configuration and validation of a git ref or commit id.
      # This module is similar to {Rosette::Core::Commands::WithRef} except that
      # it will fail to validate merge refs. It is meant to be mixed into the classes
      # in {Rosette::Core::Commands}. Required to be used in combination with
      # {Rosette::Core::Commands::WithRepoName}.
      #
      # @see Rosette::Core::Commands::WithRef
      # @see Rosette::Core::Commands::WithRepoName
      #
      # @example
      #   class MyCommand
      #     include WithRepoName
      #     include WithNonMergeRef
      #   end
      #
      #   cmd = MyCommand.new
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #
      #   cmd.commit_str  # => "master"
      #   cmd.commit_id   # => "67f0e9a60dfe39430b346086f965e6c94a8ddd24"
      #
      #   cmd.set_ref('non_existant_ref')
      #   cmd.valid?    # => false
      #   cmd.messages  # => { commit_str: ["Unable to find commit 'non_existent_ref'"] }
      module WithNonMergeRef
        include WithRef

        protected

        def self.included(base)
          if base.respond_to?(:validate)
            base.validate :commit_str, {
              type: :commit, allow_merge_commit: false
            }
          end
        end
      end

    end
  end
end
