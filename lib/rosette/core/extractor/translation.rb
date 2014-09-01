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
    end

  end
end
