# encoding: UTF-8

module Rosette
  module Core

    # Defines the logic for which field should be used to index a phrase.
    # Phrases can be indexed either by key or meta key. The logic in this
    # module is designed to determine which of these fields to use for a
    # particular phrase, taking into consideration +nil+ and blank values.
    # By default, phrases are indexed by meta key. If however a phrase has
    # a +nil+ or blank meta key, the key should be used as the index value
    # instead.
    #
    # Must be mixed into an object that responds to {Phrase} methods,
    # specifically +key+ and +meta_key+.
    #
    # @example
    #   class MyPhrase
    #     include PhraseIndexPolicy
    #
    #     attr_accessor :key, :meta_key
    #
    #     def initialize(key, meta_key)
    #       @key = key; @meta_key = meta_key
    #     end
    #   end
    #
    #   p = MyPhrase.new('foo', 'bar')
    #   p.index_key    # => :meta_key
    #   p.index_value  # => 'bar'
    #
    #   p = MyPhrase.new('foo', nil)
    #   p.index_key    # => :key
    #   p.index_value  # => 'foo'
    #
    #   p = MyPhrase.new(nil, nil)
    #   p.index_key    # => :key
    #   p.index_value  # => ''
    #
    # @see Rosette::Core::Phrase
    module PhraseIndexPolicy
      # Determines which key should be used for indexing.
      #
      # @param [String] key The phrase key.
      # @param [String] meta_key The phrase meta key.
      # @return [Symbol] either +:key+ or +:meta_key+.
      def self.index_key(key, meta_key)
        if !meta_key || meta_key.empty?
          :key
        else
          :meta_key
        end
      end

      # Determines which value should be used for indexing.
      #
      # @param [String] key The phrase key.
      # @param [String] meta_key The phrase meta_key.
      # @return [String] either the given key or meta key, or an empty string
      #   if the value is +nil+. In other words, if the value at +#index_key+
      #   is +nil+, returns an empty string.
      def self.index_value(key, meta_key)
        value = case index_key(key, meta_key)
          when :key then key
          else meta_key
        end

        case value
          when NilClass
            ''
          else
            value
        end
      end

      # Determines which key should be used for indexing.
      #
      # @return [Symbol] either +:key+ or +:meta_key+.
      def index_key
        PhraseIndexPolicy.index_key(key, meta_key)
      end

      # Determines which value should be used for indexing.
      #
      # @return [String] either the given key or meta key, or an empty string
      #   if the value is +nil+. In other words, if the value at +#index_key+
      #   is +nil+, returns an empty string.
      def index_value
        PhraseIndexPolicy.index_value(key, meta_key)
      end

      protected

      def self.included(base)
        base.class_eval do
          def self.index_key(key, meta_key)
            PhraseIndexPolicy.index_key(key, meta_key)
          end

          def self.index_value(key, meta_key)
            PhraseIndexPolicy.index_value(key, meta_key)
          end
        end
      end
    end

  end
end
