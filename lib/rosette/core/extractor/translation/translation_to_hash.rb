# encoding: UTF-8

module Rosette
  module Core

    module TranslationToHash
      def to_h
        { locale: locale, translation: translation, phrase: phrase.to_h }
      end
    end

  end
end
