# encoding: UTF-8

module Rosette
  module Tms
    class Repository

      # Creates a new instance of this repository.
      #
      # @param [Object] configurator The implementation-specific configuration
      #   object for this repository.
      # @return [Repository]
      def initialize(configurator)
      end

      # Retrieves a list of translations for the given phrases.
      #
      # @param [Locale] locale The locale of the translations to retrieve.
      # @param [Array<Phrase>] phrases The list of phrases to retrieve
      #   translations for.
      # @return [Array<String>] an array of translations (note that the array
      #   contains strings, not [Translation] instances). The array may also
      #   contain +nil+ entries where translations could not be found.
      def lookup_translations(locale, phrases)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Retrieves a single translation for the given phrase.
      #
      # @param [Locale] locale The locale of the translation to retrieve.
      # @param [Phrase] phrase The phrase to retrieve the translation for.
      # @return [String] the translation or nil of one cannot be found.
      def lookup_translation(locale, phrase)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Publishes a list of phrases in the repository. For web-based translation
      # management systems, this probably means uploading phrases to be
      # translated over HTTP.
      #
      # @param [Array<Phrase>] phrases The list of phrases to store.
      # @param [String] commit_id The commit id to associate the phrases with.
      # @return [void]
      def store_phrases(phrases, commit_id)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Publishes a phrase in the repository. For web-based translation
      # management systems, this probably means uploading the phrase over HTTP.
      #
      # @param [Phrase] phrase The phrase to store.
      # @param [String] commit_id The commit id to associate the phrase with.
      # @return [void]
      def store_phrase(phrase, commit_id)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Calculates a single unique value for the phrases and translations
      # associated with a given commit id. Often this is calculated using a
      # one-way hash like MD5 or SHA1. Checksum values can be compared to
      # determine when translations for the given commit id have changed.
      #
      # @param [Locale] locale The locale to calculate the checksum for.
      # @param [String] commit_id The commit id that contains the phrases and
      #   translations to calculate the checksum for.
      # @return [String] the calculated checksum value
      def checksum_for(locale, commit_id)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Collects and calculates status information for the phrases contained in
      # the given commit as well as their translations per locale.
      #
      # @param [String] commit_id The commit id to calculate the status for.
      # @return [TranslationStatus]
      def status(commit_id)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Signals the repository to perform any cleanup tasks that may be required
      # for the given commit once it's been fully translated.
      #
      # @param [String] commit_id
      def finalize(commit_id)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

    end
  end
end
