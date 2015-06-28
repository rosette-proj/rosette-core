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
        #   * +status+: One of +"FETCHED"+, +"EXTRACTED"+, +"PUSHED"+,
        #     +"FINALIZED"+, or +"NOT FOUND"+.
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
          all_refs = repo_config.repo.all_refs.values
          refs = repo_config.repo.refs_containing(
            commit_id, rev_walk, all_refs
          )

          commit_logs = commit_logs_for(
            refs.map(&:getName), repo_config, rev_walk, all_refs
          )

          status, phrase_count, locale_statuses = derive(
            refs, commit_logs, repo_config
          )

          rev_walk.dispose

          {
            status: status,
            commit_id: commit_id,
            phrase_count: phrase_count,
            locales: locale_statuses
          }
        end

        protected

        def derive(refs, commit_logs, repo_config)
          status = derive_status(refs, commit_logs)
          phrase_count = BranchUtils.derive_phrase_count_from(commit_logs)
          locale_statuses = BranchUtils.derive_locale_statuses_from(
            commit_logs, repo_name, datastore, phrase_count
          )

          [
            status, phrase_count,
            BranchUtils.fill_in_missing_locales(
              repo_config.locales, locale_statuses
            )
          ]
        end

        def derive_status(refs, commit_logs)
          if all_refs_exist?(refs)
            BranchUtils.derive_status_from(commit_logs)
          else
            Rosette::DataStores::PhraseStatus::NOT_FOUND
          end
        end

        def all_refs_exist?(refs)
          refs.all? do |ref|
            datastore.commit_log_exists?(repo_name, ref.getObjectId.name)
          end
        end

        def commit_logs_for(branch_names, repo_config, rev_walk, refs)
          statuses = Rosette::DataStores::PhraseStatus.incomplete
          commit_logs = datastore.each_commit_log_with_status(repo_name, statuses)

          commit_logs.each_with_object([]) do |commit_log, ret|
            refs = repo_config.repo.refs_containing(
              commit_log.commit_id, rev_walk, refs
            )

            if refs.any? { |ref| branch_names.include?(ref.getName) }
              ret << commit_log
            end
          end
        end
      end

    end
  end
end
