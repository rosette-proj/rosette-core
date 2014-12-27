# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Represents an added, removed, or changed phrase.
      #
      # @!attribute [r] phrase
      #   @return [Rosette::Core::Phrase] the added/removed/modified phrase.
      # @!attribute [r] state
      #   @return [Symbol] one of +:added+, +:removed+, or +:modified+.
      # @!attribute [r] old_phrase
      #   @return [Rosette::Core::Phrase] +phrase+ before it was modified.
      #     This value is generally only set if +state+ is set to +:modified+.
      class DiffEntry
        attr_reader :phrase, :state, :old_phrase

        # Creates a new {DiffEntry}.
        #
        # @param [Rosette::Core::Phrase] phrase The added/removed/modified phrase.
        # @param [Symbol] state One of +:added+, +:removed+, or +:modified+.
        # @param [Rosette::Core::Phrase] old_phrase +phrase+ before it was modified.
        #   This argument is usually only included if +state+ is +:modified+.
        def initialize(phrase, state, old_phrase = nil)
          @phrase = phrase
          @state = state
          @old_phrase = old_phrase
        end

        # Serializes the attributes of this entry into a hash.
        #
        # @return [Hash] the attributes of the phrase. If +state+ is set to +:modified+,
        #   the key of the old phrase is included as +:old_key+.
        def to_h
          phrase.to_h.tap do |hash|
            hash[:old_key] = old_phrase.key if old_phrase
          end
        end
      end

    end
  end
end
