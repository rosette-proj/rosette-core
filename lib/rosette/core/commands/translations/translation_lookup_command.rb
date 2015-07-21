# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Returns the translation for the given phrase and locale combination.
      #
      # @!attribute [r] locale
      #   @return [String] the locale to export translations for.
      #
      # @example
      #   cmd = TranslationLookupCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_locale('es')
      #     .set_meta_key('my.phrase')
      #     .set_key('I am a phrase')
      #
      #   cmd.execute
      #   # => "Soy una frase"
      #
      # @!attribute [r] locale
      #   @return [String] the locale of the translation to look up.
      # @!attribute [r] repo_name
      #   @return [String] the name of the repo the phrase (and therefore the
      #     translation) belongs to.
      # @!attribute [r] key
      #   @return [String] the phrase key.
      # @!attribute [r] meta_key
      #   @return [String] the phrase meta key.
      class TranslationLookupCommand < GitCommand
        attr_reader :key, :meta_key

        include WithRepoName
        include WithLocale

        def set_key(key)
          @key = key
          self
        end

        def set_meta_key(meta_key)
          @meta_key = meta_key
          self
        end

        def execute
          phrase = datastore.lookup_phrase(repo_name, key, meta_key, commit_id)
          repo_config.tms.lookup_translation(locale_obj, phrase)
        end

        protected

        def repo_config
          configuration.get_repo(repo_name)
        end

        def locale_obj
          repo_config.locales.find { |l| l.code == locale }
        end
      end

    end
  end
end
