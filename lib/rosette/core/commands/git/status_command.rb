# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Computes the status of a git ref. Statuses contain the number of
      # translations per locale as well as the state of the commit (pending,
      # untranslated, or translated).
      #
      # @see Rosette::DataStores::PhraseStatus
      #
      # @example
      #   cmd = StatusCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #
      #   cmd.execute
      #   # =>
      #   # {
      #   #   commit_id: "5756196042a3a307b43fd1a7092ecc6710eec42a",
      #   #   status: "PENDING",
      #   #   phrase_count: 100,
      #   #   locales: [{
      #   #     locale: 'fr-FR',
      #   #     percent_translated: 0.5,
      #   #     translated_count: 50
      #   #   }, ... ]
      #   # }
      class StatusCommand < GitCommand
        include WithRepoName
        include WithRef

        # Computes the status for the configured repository and git ref. The
        # status is computed by identifying the branch the ref belongs to, then
        # examining and merging the statuses of all commits that belong to
        # that branch.
        #
        # @see Rosette::DataStores::PhraseStatus
        #
        # @return [Hash] a hash of status information for the ref:
        #   * +commit_id+: the commit id of the ref the status came from.
        #   * +status+: One of +"PENDING"+, +"UNTRANSLATED"+, or +"TRANSLATED"+.
        #   * +phrase_count+: The number of phrases found in the commit.
        #   * +locales+: A hash of locale codes to locale statuses having these
        #     entries:
        #     * +percent_translated+: The percentage of +phrase_count+ phrases
        #       that are currently translated in +locale+ for this commit.
        #       In other words, +translated_count+ +/+ +phrase_count+.
        #     * +translated_count+: The number of translated phrases in +locale+
        #       for this commit.
        def execute
          repo_config = get_repo(repo_name)
          rev_walk = RevWalk.new(repo_config.repo.jgit_repo)
          refs = repo_config.repo.remote_refs_for_commit(
            commit_id, rev_walk
          )

          commit_logs = commit_logs_for(refs.map(&:getName), repo_config, rev_walk)
          status = derive_status_from(commit_logs)
          phrase_count = derive_phrase_count_from(commit_logs)
          locale_statuses = derive_locale_statuses_from(commit_logs)

          {
            status: status,
            phrase_count: phrase_count,
            locales: fill_in_missing_locales(
              repo_config.locales, locale_statuses
            )
          }
        end

        protected

        def derive_status_from(commit_logs)
          ps = Rosette::DataStores::PhraseStatus
          entry = commit_logs.min_by { |entry| ps.index(entry.status) }
          entry.status if entry
        end

        def derive_phrase_count_from(commit_logs)
          commit_logs.inject(0) { |sum, entry| sum + entry.phrase_count }
        end

        def derive_locale_statuses_from(commit_logs)
          commit_logs.each_with_object({}) do |commit_log, ret|
            locale_entries = datastore.commit_log_locales_for(repo_name, commit_log.commit_id)
            locale_entries.each do |locale_entry|
              ret[locale_entry.locale] ||= { translated_count: 0 }

              ret[locale_entry.locale].tap do |locale_hash|
                locale_hash[:translated_count] += locale_entry.translated_count
                locale_hash[:percent_translated] = percentage(
                  commit_log.phrase_count || 0,
                  locale_hash.fetch(:translated_count, 0) || 0
                )
              end
            end
          end
        end

        def commit_logs_for(branch_names, repo_config, rev_walk)
          statuses = Rosette::DataStores::PhraseStatus.incomplete
          commit_logs = datastore.each_commit_log_with_status(repo_name, statuses)

          commit_logs.each_with_object([]) do |commit_log, ret|
            refs = repo_config.repo.remote_refs_for_commit(
              commit_log.commit_id, rev_walk
            )

            if refs.any? { |ref| branch_names.include?(ref.getName) }
              ret << commit_log
            end
          end
        end

        def fill_in_missing_locales(locales, locale_statuses)
          locales.each_with_object({}) do |locale, ret|
            if found_locale_status = locale_statuses[locale.code]
              ret[locale.code] = found_locale_status
            else
              ret[locale.code] = {
                locale: locale.code,
                percent_translated: 0.0,
                translated_count: 0
              }
            end
          end
        end

        def percentage(dividend, divisor)
          if divisor > 0
            (dividend.to_f / divisor.to_f).round(2)
          else
            0.0
          end
        end
      end

    end
  end
end
