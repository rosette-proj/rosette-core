# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Adds a new translation or updates an existing one.
      #
      # @!attribute [r] key
      #   @return [String] the key of the translation's associated phrase
      #     entry.
      # @!attribute [r] meta_key
      #   @return [String] the meta key of the translation's associated
      #     phrase entry.
      # @!attribute [r] translation
      #   @return [String] the translation text.
      # @!attribute [r] locale
      #   @return [String] the locale +translation+ is written in.
      #
      # @example
      #   cmd = AddOrUpdateTranslationCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #     .set_locale('es-ES')
      #     .set_key("I'm a little teapot")
      #     .set_meta_key('teapot_text')
      #     .set_translation("Soy una tetera pequeña")
      #     .execute
      class AddOrUpdateTranslationCommand < GitCommand
        attr_reader :key, :meta_key, :translation, :locale

        include WithRepoName
        include WithRef
        include WithLocale

        # Sets the key used to identify the translation's phrase entry.
        #
        # @param [String] key The phrase's key.
        # @return [self]
        def set_key(key)
          @key = key
          self
        end

        # Sets the meta key used to identify the translation's phrase entry.
        #
        # @param [String] meta_key The phrase's meta key.
        # @return [self]
        def set_meta_key(meta_key)
          @meta_key = meta_key
          self
        end

        # Sets the translation text.
        #
        # @param [String] translation The translation's text.
        # @return [self]
        def set_translation(translation)
          @translation = translation
          self
        end

        # Adds or updates the translation. If the corresponding phrase can be
        # identified using +key+ and/or +meta_key+, then the translation is
        # considered associated with that phrase. If no associated phrase can
        # be found, a {Rosette::DataStores::Errors::PhraseNotFoundError} is logged
        # via Rosette's error reporter. Once the phrase has been identified,
        # +execute+ tries to find a translation with the same locale. If one can
        # be found, it updates the entry's translation text. If an existing
        # translation entry cannot be found, one is created with the given
        # locale and translation text and associated with the phrase.
        #
        # @see Configurator#error_reporter
        #
        # @return [void]
        def execute
          datastore.add_or_update_translation(
            repo_name, {
              key: key,
              meta_key: meta_key,
              commit_id: commit_id,
              translation: translation,
              locale: locale
            }
          )
        end

      end
    end
  end
end
