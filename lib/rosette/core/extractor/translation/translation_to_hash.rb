# encoding: UTF-8

module Rosette
  module Core

    # Turns a {Translation} into a hash. Must be mixed into a {Translation}-like
    # class.
    #
    # @example
    #   t = Translation.new
    #   t.translation = 'foó'
    #   t.locale = 'fr-FR'
    #   t.phrase = Phrase.new
    #
    #   t.to_h  # => { translation: 'foó', locale: 'fr-FR', phrase: { ... } }
    module TranslationToHash
      # Converts the attributes of a {Translation} into a hash of attributes.
      # This includes the attributes of the associated {Phrase} object, which
      # is also converted to a hash via the {PhraseToHash} module.
      #
      # @return [Hash] a hash of translation attributes.
      def to_h
        { locale: locale, translation: translation, phrase: phrase.to_h }
      end
    end

  end
end
