# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Inspects the given commit and extracts translatable phrases using the configured
      # extractors. By design, {CommitCommand} (and the rest of Rosette) will not process
      # merge commits. Generally, a snapshot of the repository will be necessary to
      # find the commits where individual files were last changed (see the
      # {RepoSnapshotCommand} or {SnapshotFactory} class to take snapshots).
      #
      # @see Rosette::Core::Commands::RepoSnapshotCommand
      # @see Rosette::Core::SnapshotFactory
      #
      # @example
      #   CommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #     .execute
      #
      # @example
      #   CommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_commit_id('67f0e9a60dfe39430b346086f965e6c94a8ddd24')
      #     .execute
      class CommitCommand < GitCommand
        include WithRepoName
        include WithNonMergeRef

        # Executes the command. Causes phrases to be extracted from the given git ref or
        # commit id and written to the configured data store, triggering hooks in the process.
        #
        # @return [nil]
        def execute
          commit_processor.process_each_phrase(repo_name, commit_id) do |phrase|
            datastore.store_phrase(repo_name, phrase)
          end

          rev_commit = get_repo(repo_name).repo.get_rev_commit(commit_id)
          datastore.add_or_update_commit_log(repo_name, commit_id, Time.at(rev_commit.getCommitTime))
          trigger_hooks(:after)
          nil
        end

        private

        def commit_processor
          @commit_processor ||= Rosette::Core::CommitProcessor.new(configuration)
        end

        def trigger_hooks(stage)
          repo_config = get_repo(repo_name)
          repo_config.hooks.fetch(stage, {}).fetch(:commit, []).each do |hook_proc|
            hook_proc.call(configuration, repo_config, commit_id)
          end
        end
      end

    end
  end
end
