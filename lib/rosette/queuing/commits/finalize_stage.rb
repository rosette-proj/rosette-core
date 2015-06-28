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

        # Executes this stage and updates the commit log. If the commit has been
        # fully translated, the commit log will be updated with a +FINALIZED+
        # status, and the +finalize+ method will be called on the translation
        # management system. If the commit has not been fully translated, the
        # commit log's status won't be updated and +finalize+ will not be
        # called. In both cases, commit log locale entries will be updated to
        # track translation progress.
        #
        # @return [void]
        def execute!
          logger.info("Finalizing commit #{commit_log.commit_id}")

          status = repo_config.tms.status(commit_log.commit_id)

          repo_config.locales.each do |locale|
            locale_code = locale.code

            rosette_config.datastore.add_or_update_commit_log_locale(
              commit_log.commit_id, locale_code, status.locale_count(locale_code)
            )
          end

          if status.fully_translated?
            repo_config.tms.finalize(commit_log.commit_id)
            commit_log.finalize
            save_commit_log
          end

          logger.info("Finished finalizing commit #{commit_log.commit_id}")
        end
      end

    end
  end
end
