# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Performs cleanup tasks for the given commit as defined by the configured
      # translation management system.
      #
      # @see RepoConfig
      class FinalizeStage < Stage
        accepts PhraseStatus::PUSHED

        # Executes this stage and updates the commit log with a +FINALIZED+
        # status. Calls the +finalize+ method on the translation management
        # system.
        #
        # @return [void]
        def execute!
          logger.info("Finalizing commit #{commit_log.commit_id}")

          repo_config.tms.finalize(commit_log.commit_id)
          commit_log.finalize
          save_commit_log

          logger.info("Finished finalizing commit #{commit_log.commit_id}")
        end
      end

    end
  end
end
