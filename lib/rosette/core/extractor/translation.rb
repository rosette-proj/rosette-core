# encoding: UTF-8

module Rosette
  module Core

    # Represents a translation. Translations always have an associated phrase,
    # a locale, and some translated text.
    #
    # @!attribute [r] phrase
    #   @return [Phrase] the associated phrase object.
    # @!attribute [r] locale
    #   @return [String] the locale code.
    # @!attribute [r] translation
    #   @return [String] the translation text.
    class Translation
      include TranslationToHash

      attr_reader :phrase, :locale, :translation

      # Creates a new translation object.
      #
      # @param [Phrase] phrase The associated phrase object.
      # @param [String] locale The locale code.
      # @param [String] translation The translated text.
      def initialize(phrase, locale, translation)
        @phrase = phrase
        @locale = locale
        @translation = translation
      end

      # Turns this translation object into a hash.
      #
      # @return [Hash] a hash with +phrase+ as a hash, +locale+, and
      #   +translation+.
      def self.from_h(hash)
        new(
          Phrase.from_h(hash[:phrase]),
          hash[:locale], hash[:translation]
        )
      end
    end

  end
end
