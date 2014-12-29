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

        # Computes the status for the configured repository and git ref.
        #
        # @see Rosette::DataStores::PhraseStatus
        #
        # @return [Hash] a hash of status information for the commit:
        #   * +commit_id+: the commit id of the ref the status came from.
        #     This may or may not be the ref or commit id set via {#set_ref}
        #     or {#set_commit_id}, since Rosette does not process merge refs.
        #     If the configured ref or commit id is a merge ref, the status
        #     for the most recent non-merge parent is returned instead.
        #   * +status+: One of +"PENDING"+, +"UNTRANSLATED"+, or +"TRANSLATED"+.
        #   * +phrase_count+: The number of phrases found in the commit.
        #   * +locales+: An array of locale statuses having these entries:
        #     * +locale+: The locale code.
        #     * +percent_translated+: The percentage of +phrase_count+ phrases
        #       that are currently translated in +locale+ for this commit.
        #       In other words, +translated_count+ +/+ +phrase_count+.
        #     * +translated_count+: The number of translated phrases in +locale+
        #       for this commit.
        def execute
          repo_config = get_repo(repo_name)
          locales = repo_config.locales.map(&:code)
          parent = repo_config.repo.find_first_non_merge_parent(commit_id)

          datastore.commit_log_status(repo_name, parent.getId.name).tap do |status|
            if status
              status[:locales] = fill_in_missing_locales(locales, status)
            end
          end
        end

        protected

        def fill_in_missing_locales(locales, status)
          locales.map do |locale|
            found_locale = status[:locales].find do |status_locale|
              status_locale[:locale] == locale
            end

            if found_locale
              found_locale
            else
              {
                locale: locale,
                percent_translated: 0.0,
                translated_count: 0
              }
            end
          end
        end
      end

    end
  end
end
