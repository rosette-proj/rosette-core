# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Returns the list of phrases per locale that have not yet been translated
      # for the given repo and commit.
      #
      # @example
      #   cmd = UntranslatedPhrasesCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #
      #   cmd.execute
      #   # => {
      #       "fr-FR" => [
      #         <Phrase>, <Phrase>, ...
      #       ]
      #   # }
      class UntranslatedPhrasesCommand < GitCommand
        include WithRepoName
        include WithRef

        def execute
          phrases = datastore.phrases_by_commit(repo_name, commit_id)
          result = Hash.new { |h, k| h[k] = [] }

          repo_config.locales.each_with_object(result) do |locale, ret|
            phrases.each do |phrase|
              trans = repo_config.tms.lookup_translation(locale, phrase)
              result[locale.code] << phrase
            end
          end
        end

        protected

        def repo_config
          get_repo(repo_name)
        end
      end

    end
  end
end
