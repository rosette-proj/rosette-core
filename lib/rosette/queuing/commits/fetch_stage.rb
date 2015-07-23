# encoding: UTF-8

java_import 'org.eclipse.jgit.api.Git'

module Rosette
  module Queuing
    module Commits

      # Fetches the repository. This should be the first commit processing stage
      # since it ensures the given commit is available in the repository for
      # processing.
      #
      # @see RepoConfig
      class FetchStage < Stage
        accepts PhraseStatus::NOT_SEEN, PhraseStatus::NOT_FOUND

        # Executes this stage and updates the commit log with a +FETCHED+
        # status. Performs a git fetch.
        #
        # @return [void]
        def execute!
          logger.info("Fetching git repository #{repo_config.name}")

          git.fetch
            .setRemote('origin')
            .setRemoveDeletedRefs(true)
            .call

          commit_log.fetch

          # git won't know about the commit before a fetch, which is why branch
          # name is set in this stage and not when the commit is first enqueued
          commit_log.branch_name = Rosette::Core::BranchUtils.derive_branch_name(
            commit_log.commit_id, repo_config.repo
          )

          save_commit_log

          logger.info("Finished fetching git repository #{repo_config.name}")
        end

        private

        def git
          @git ||= Git.new(repo_config.repo.jgit_repo)
        end
      end

    end
  end
end
