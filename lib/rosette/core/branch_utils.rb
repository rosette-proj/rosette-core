# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    # Utility methods that work at the branch level.
    class BranchUtils
      class << self

        # Computes the status for an array of commit logs. Determining the
        # aggregate status of more than one commit log means choosing the least
        # far-along status from the list. In other words, if the list contains
        # two commit logs with FETCHED and FINALIZED statuses respectively, this
        # method will return FETCHED because that's the least advanced status in
        # the list. A list of commit logs is only as advanced as its 'weakest',
        # least advanced element.
        #
        # @param [Array<CommitLog>] commit_logs The list of commit logs to
        #   derive the status from.
        # @return [PhraseStatus]
        def derive_status_from(commit_logs)
          ps = Rosette::DataStores::PhraseStatus
          entry = commit_logs.min_by { |entry| ps.index(entry.status) }

          if entry
            entry.status
          else
            # since FINALIZED commit_logs aren't considered, the absence of any
            # commit logs (i.e. a nil entry) indicates the branch is fully
            # processed
            Rosette::DataStores::PhraseStatus::FINALIZED
          end
        end

        # Computes the phrase count for the given list of commit logs. This is
        # simply the sum of all the commit log's phrase counts.
        #
        # @param [Array<CommitLog>] commit_logs The list of commit logs to
        #   compute the phrase count from.
        # @return [Fixnum]
        def derive_phrase_count_from(commit_logs)
          commit_logs.inject(0) { |sum, entry| sum + entry.phrase_count }
        end

        # Computes the status for each individual locale contained in the
        # given list of commit logs. Locale statuses are hashes that contain a
        # count of the number of translated phrases for that locale as well as
        # the percent translated.
        #
        # @param [Array<CommitLog>] commit_logs The list of commit logs to
        #   compute locale statuses from.
        # @param [String] repo_name The name of the repo these commit logs came
        #   from.
        # @param [Object] datastore The datastore to query for locale data.
        # @param [Fixnum] phrase_count The aggregate number of phrases for the
        #   list of commit logs. If +nil+, the +derive_phrase_count+ method
        #   will be called to fill in this parameter.
        # @return [Hash] the locale status hash. Contains locale codes as
        #   top-level keys and hashes as values. Each locale hash contains the
        #   keys +:translated_count+ and +:percent_translated+.
        def derive_locale_statuses_from(commit_logs, repo_name, datastore, phrase_count = nil)
          phrase_count ||= derive_phrase_count_from(commit_logs)

          locale_statuses = commit_logs.each_with_object({}) do |commit_log, ret|
            locale_entries = datastore.commit_log_locales_for(
              repo_name, commit_log.commit_id
            )

            locale_entries.each do |locale_entry|
              ret[locale_entry.locale] ||= { translated_count: 0 }

              ret[locale_entry.locale].tap do |locale_hash|
                locale_hash[:translated_count] += locale_entry.translated_count
              end
            end
          end

          add_translation_percentages(locale_statuses, phrase_count)
        end

        # Adds any missing locale keys to a hash of locale statuses.
        #
        # @param [Array<Locale>] all_locales The complete list of locales that
        #   +locale_statuses+ should contain.
        # @param [Hash] locale_statuses The locale statuses hash such as is
        #   returned by +derive_locale_statuses_from+.
        # @return [Hash] a copy of +locale_statuses+ that contains entries for
        #   all the locales in +all_locales+. Any locale entries missing from
        #   +locale_statuses+ will have been filled in with blank data, i.e.
        #   +:translated_count+ will be 0 and +:percent_translated+ will be 0.0.
        def fill_in_missing_locales(all_locales, locale_statuses)
          all_locales.each_with_object({}) do |locale, ret|
            if found_locale_status = locale_statuses[locale.code]
              ret[locale.code] = found_locale_status
            else
              ret[locale.code] = {
                percent_translated: 0.0,
                translated_count: 0
              }
            end
          end
        end

        def derive_branch_name(commit_id, repo)
          refs = repo.refs_containing(commit_id).map(&:getName)

          if refs.include?('refs/remotes/origin/master')
            'refs/remotes/origin/master'
          else
            filter_refs(refs).first
          end
        end

        private

        def filter_refs(refs)
          refs.each_with_object([]) do |ref, ret|
            ret << ref if valid_ref?(ref)
          end
        end

        def valid_ref?(ref_text)
          ref = Rosette::Core::Ref.parse(ref_text)
          ref && ref.remote? && ref.name != 'master' && ref.name != 'HEAD'
        end

        def add_translation_percentages(locale_statuses, phrase_count)
          locale_statuses.each_with_object({}) do |(locale, locale_status), ret|
            ret[locale] = locale_status.merge(
              percent_translated: percentage(
                locale_status.fetch(:translated_count, 0) || 0,
                phrase_count || 0
              )
            )
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
