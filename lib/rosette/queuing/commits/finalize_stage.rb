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

        # The number of seconds to wait in between consecutive pulls. This value
        # will be passed to the queue implementation, as delay is handled at the
        # queue layer.
        CONSECUTIVE_FINALIZE_DELAY_MIN = 10 * 60  # 10 minutes
        CONSECUTIVE_FINALIZE_DELAY_MAX = 45 * 60  # 45 minutes

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

        # Converts this stage to a job that can be enqueued. This method should
        # be called after +#execute!+, meaning the commit log has been updated
        # to the next status in the pipeline. If that next status also happens
        # to be PUSHED, this method adds a delay to avoid finalizing too often.
        # If the chosen queue implementation does not support delays, setting
        # this value should be a safe no-op (i.e. have no adverse side-effects).
        #
        # @return [CommitJob]
        def to_job
          super.tap do |job|
            if commit_log.status == PhraseStatus::PUSHED
              job.set_delay(random_delay)
              job.set_queue('finalize')
            end
          end
        end

        protected

        def random_delay
          rand(CONSECUTIVE_FINALIZE_DELAY_MIN..CONSECUTIVE_FINALIZE_DELAY_MAX)
        end
      end

    end
  end
end
