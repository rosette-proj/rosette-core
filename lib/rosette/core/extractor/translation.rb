# encoding: UTF-8

module Rosette
  module Core

    class Translation
      include TranslationToHash

      attr_reader :phrase, :locale, :translation

      def initialize(phrase, locale, translation)
        @phrase = phrase
        @locale = locale
        @translation = translation
      end

      def self.from_h(hash)
        new(
          Phrase.from_h(hash[:phrase]),
          hash[:locale], hash[:translation]
        )
      end
    end

  end
end
