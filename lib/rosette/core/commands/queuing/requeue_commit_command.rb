# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Sets the commit's status to NOT_FOUND, then enqueues it for processing
      # on Rosette's configured queue. In other words, this command will
      # re-process the commit, which should be an idempotent operation.
      #
      # @see Rosette::Queuing
      #
      # @example
      #   RequeueCommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #     .execute
      #
      # @example
      #   RequeueCommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_commit_id('67f0e9a60dfe39430b346086f965e6c94a8ddd24')
      #     .execute
      class RequeueCommitCommand < GitCommand
        include WithRepoName
        include WithRef

        def execute
          commit_log = datastore.lookup_commit_log(repo_name, commit_id)

          datastore.add_or_update_commit_log(
            commit_log.repo_name, commit_log.commit_id,
            commit_log.commit_datetime, PhraseStatus::NOT_FOUND,
            commit_log.phrase_count, commit_log.branch_name
          )

          EnqueueCommitCommand.new(configuration)
            .set_repo_name(repo_name)
            .set_commit_id(commit_id)
            .execute
        end
      end

    end
  end
end
