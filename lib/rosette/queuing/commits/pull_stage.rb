# encoding: UTF-8

require 'concurrent'

module Rosette
  module Queuing
    module Commits

      # Retrieves (or "pulls") a set of translations for the given commit from
      # the configured translation management system. The translations are
      # associated with the configured commit via that commit's phrases.
      #
      # @see RepoConfig
      class PullStage < Stage
        accepts PhraseStatus::PENDING, PhraseStatus::PULLING

        # The number of seconds to wait in between consecutive pulls. This value
        # will be passed to the queue implementation, as delay is handled at the
        # queue layer.
        CONSECUTIVE_PULL_DELAY = 10 * 60  # 10 minutes

        # The number of threads to use when syncing locales. One thread per locale.
        THREAD_POOL_SIZE = 5

        # Enables or disables caching of tms checksums. If set to true, +PullStage+
        # will skip pulling if it notices that translations haven't changed between
        # consecutive pulls.
        ENABLE_CHANGE_CACHE = false

        # Executes this stage and updates the commit log. If the given commit
        # contains no phrases, this method doesn't pull but will still update
        # the commit log (status will be +TRANSLATED+). If the commit no longer
        # exists in the git repository, (eg. it was force pushed over, etc), the
        # commit log will be updated with a MISSING status. If the commit does
        # in fact contain phrases, the commit log will be updated with a
        # +PULLING+ status. If the commit contains phrases and they are fully
        # translated in every locale, the commit log will be updated with a
        # +PULLED+ status.
        #
        # @return [void]
        def execute!
          logger.info("Pulling commit #{commit_log.commit_id}")

          commit_id = commit_log.commit_id
          snapshot = snapshot_for(commit_id)
          phrases = phrases_for(snapshot)
          commit_ids = commit_ids_from(phrases)

          sync_locales(phrases, commit_ids)
          update_logs

          logger.info("Finished pulling commit #{commit_log.commit_id}")
        rescue Java::OrgEclipseJgitErrors::MissingObjectException => e
          commit_log.missing
        ensure
          save_commit_log
        end

        # Converts this stage to a job that can be enqueued. This method should
        # be called after +#execute!+, meaning the commit log has been updated
        # to the next status in the pipeline. If that next status also happens
        # to be a pull, this method adds a delay to avoid pulling too often. If
        # the chosen queue implementation does not support delays, setting this
        # value should be a safe no-op (i.e. have no adverse side-effects).
        #
        # @return [CommitJob]
        def to_job
          super.tap do |job|
            if commit_log.status == PhraseStatus::PULLING
              job.set_delay(CONSECUTIVE_PULL_DELAY)
            end
          end
        end

        protected

        def update_logs
          status = repo_config.tms.status(commit_log.commit_id)

          if commit_log.phrase_count == 0
            commit_log.translate!
          else
            commit_log.pull(fully_translated: status.fully_translated?)
          end

          repo_config.locales.each do |locale|
            rosette_config.datastore.add_or_update_commit_log_locale(
              commit_log.commit_id, locale.code, status.locale_count(locale.code)
            )
          end
        end

        def cache_checksum_for(locale)
          rosette_config.cache.write(
            tms_checksum_key(locale),
            tms.checksum_for(locale, commit_log.commit_id)
          )
        end

        def sync_locales(phrases, commit_ids)
          pool = Concurrent::FixedThreadPool.new(THREAD_POOL_SIZE)

          repo_config.locales.each do |locale|
            pool << Proc.new { sync_locale(locale, phrases, commit_ids) }
            cache_checksum_for(locale)
          end

          drain_pool(pool)
        end

        def drain_pool(pool)
          pool.shutdown
          last_completed_count = 0

          while pool.shuttingdown?
            sleep 1
          end
        end

        def sync_locale(locale, phrases, commit_ids)
          if should_import_translations?(locale)
            phrases.each do |phrase|
              sync_phrase(phrase, locale, commit_ids)
            end
          end
        end

        def sync_phrase(phrase, locale, commit_ids)
          if translation = tms.lookup_translation(locale, phrase)
            import_translation(
              phrase, translation, locale, commit_ids
            )
          else
            # these errors could be logged via rosette_config.error_reporter,
            # but there can be quite a lot of them, which can inundate the
            # error reporter with lots of false positives
            logger.warn(
              "No translation found for #{locale.code}, #{phrase.meta_key} " +
                "('#{phrase.key}'), #{commit_log.commit_id}"
            )
          end
        end

        def should_import_translations?(locale)
          translations_have_changed?(locale) ||
            commit_log.status == Rosette::DataStores::PhraseStatus::PENDING
        end

        def translations_have_changed?(locale)
          if ENABLE_CHANGE_CACHE
            if checksum = rosette_config.cache.read(tms_checksum_key(locale))
              checksum != tms.checksum_for(locale, commit_log.commit_id)
            else
              true
            end
          else
            # if change cache is disabled, assume that translations have always changed
            true
          end
        end

        def tms_checksum_key(locale)
          "#{repo_config.name}/tms/#{locale.code}/#{commit_log.commit_id}/checksum"
        end

        def import_translation(phrase, translation, locale, commit_ids)
          cmd = Rosette::Core::Commands::AddOrUpdateTranslationCommand.new(rosette_config)
            .set_repo_name(repo_config.name)
            .set_locale(locale.code)
            .set_translation(translation)
            .set_refs(commit_ids)

          cmd.send(:"set_#{phrase.index_key}", phrase.index_value)
          cmd.execute
        rescue Rosette::DataStores::Errors::PhraseNotFoundError => e
          rosette_config.error_reporter.report_warning(e, {
            commit_ids: commit_ids, locale: locale
          })
        end

        def commit_ids_from(phrases)
          phrases.each_with_object(Set.new) do |phrase, ret|
            ret << phrase.commit_id
          end
        end

        def snapshot_for(commit_id)
          Rosette::Core::Commands::RepoSnapshotCommand.new(rosette_config)
            .set_repo_name(repo_config.name)
            .set_commit_id(commit_id)
            .execute
        end

        def phrases_for(snapshot)
          rosette_config.datastore.phrases_by_commits(repo_config.name, snapshot).to_a
        end

        def tms
          repo_config.tms
        end
      end

    end
  end
end
