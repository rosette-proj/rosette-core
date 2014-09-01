# encoding: UTF-8

module Rosette
  module Core

    # Must be mixed into an object that responds to methods
    # named after Phrase's attributes, eg. `key`, `meta_key`, etc.
    module PhraseIndexPolicy
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

      def self.index_key(key, meta_key)
        if !meta_key || meta_key.empty?
          :key
        else
          :meta_key
        end
      end

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

      def index_key
        PhraseIndexPolicy.index_key(key, meta_key)
      end

      def index_value
        PhraseIndexPolicy.index_value(key, meta_key)
      end
    end

  end
end
