# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Saves (or "pushes") a set of phrases from the given commit to the
      # configured translation management system (TMS).
      #
      # @see RepoConfig
      class PushStage < Stage
        accepts PhraseStatus::EXTRACTED

        # Executes this stage and updates the commit log. If the commit queue
        # phrase storage granularity is set to +COMMIT+, only the phrases added
        # or modified in the given commit will get pushed to the TMS. If the
        # granularity is instead set to +BRANCH+, the full phrase diff between
        # the commit's branch and the configured diff point (usually master)
        # will get pushed to the TMS. If the commit or diff contains no phrases,
        # this method doesn't push anything but will still update the commit log
        # with a +FINALIZED+ status. If the commit no longer exists in the git
        # repository, the commit log will be updated with a status of +MISSING+.
        #
        # @return [void]
        def execute!
          logger.info("Pushing commit #{commit_log.commit_id}")

          if phrases.size > 0
            commit_log.phrase_count = phrases.size

            repo_config.tms.store_phrases(
              phrases, commit_log.commit_id, granularity
            )

            commit_log.push
          else
            commit_log.finalize!
          end

          logger.info("Finished pushing commit #{commit_log.commit_id}")
        rescue Java::OrgEclipseJgitErrors::MissingObjectException => ex
          commit_log.missing
        ensure
          save_commit_log
        end

        protected

        def granularity
          queue_config.phrase_storage_granularity
        end

        def phrases
          @phrases ||= case granularity
            when PhraseStorageGranularity::COMMIT
              phrases_from(diff_for_commit)
            when PhraseStorageGranularity::BRANCH
              phrases_from(diff_for_branch)
          end
        end

        def diff_for_commit
          Rosette::Core::Commands::ShowCommand.new(rosette_config)
            .set_repo_name(repo_config.name)
            .set_commit_id(commit_log.commit_id)
            .set_strict(false)
            .execute
        end

        def diff_for_branch
          Rosette::Core::Commands::DiffCommand.new(rosette_config)
            .set_repo_name(repo_config.name)
            .set_head_ref(commit_log.branch_name)
            .set_diff_point_ref(queue_config.diff_point)
            .set_strict(false)
            .execute
        end

        def phrases_from(diff)
          (diff[:added] + diff[:modified]).map(&:phrase)
        end
      end

    end
  end
end
