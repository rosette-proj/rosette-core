# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Saves (or "pushes") a set of phrases from the given commit to the
      # configured translation management system.
      #
      # @see RepoConfig
      class PushStage < Stage
        accepts PhraseStatus::UNTRANSLATED

        # Executes this stage and updates the commit log. If the given commit
        # contains no phrases, this method doesn't push anything but will still
        # update the commit log with a +PENDING+ status. If the commit no longer
        # exists in the git repository, the commit log will be updated with a
        # status of +MISSING+.
        #
        # @return [void]
        def execute!
          logger.info("Pushing commit #{commit_log.commit_id}")

          if phrases.size > 0
            commit_log.phrase_count = phrases.size
            repo_config.tms.store_phrases(phrases, commit_log.commit_id)
          end

          commit_log.phrase_count = phrases.size
          commit_log.push

          logger.info("Finished pushing commit #{commit_log.commit_id}")
        rescue Java::OrgEclipseJgitErrors::MissingObjectException => ex
          commit_log.missing
        ensure
          save_commit_log
        end

        protected

        def phrases
          @phrases ||= begin
            diff = Rosette::Core::Commands::ShowCommand.new(rosette_config)
              .set_repo_name(repo_config.name)
              .set_commit_id(commit_log.commit_id)
              .set_strict(false)
              .execute

            (diff[:added] + diff[:modified]).map(&:phrase)
          end
        end
      end

    end
  end
end
