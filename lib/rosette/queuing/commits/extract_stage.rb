# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Extracts phrases from the given commit and stores them in the datastore.
      #
      # @see RepoConfig
      class ExtractStage < Stage
        accepts PhraseStatus::FETCHED

        # Executes this stage and updates the commit log with an +UNTRANSLATED+
        # status. Uses [Rosette::Core::Commands::CommitCommand] under the hood.
        #
        # @return [void]
        def execute!
          Rosette::Core::Commands::CommitCommand.new(rosette_config)
            .set_repo_name(repo_config.name)
            .set_ref(commit_log.commit_id)
            .execute

          commit_log.extract
          commit_log.commit_datetime = Time.at(rev_commit.getCommitTime)

          save_commit_log
        end

        protected

        def rev_commit
          @rev_commit ||= repo_config.repo.get_rev_commit(commit_log.commit_id)
        end
      end

    end
  end
end
