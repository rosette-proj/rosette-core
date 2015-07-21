# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Enqueues a commit for processing on Rosette's configured queue.
      #
      # @see Rosette::Queuing
      #
      # @example
      #   EnqueueCommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #     .execute
      #
      # @example
      #   EnqueueCommitCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_commit_id('67f0e9a60dfe39430b346086f965e6c94a8ddd24')
      #     .execute
      class EnqueueCommitCommand < GitCommand
        include WithRepoName
        include WithRef

        def execute
          conductor = Rosette::Queuing::Commits::CommitConductor.new(
            configuration, repo_name, Rosette.logger
          )

          conductor.enqueue(commit_id)
        end
      end

    end
  end
end
