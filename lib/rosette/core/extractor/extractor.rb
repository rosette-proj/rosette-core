# encoding: UTF-8

module Rosette
  module Core

    # Extractor base class
    class Extractor
      attr_reader :config

      def initialize(config = nil)
        @config = config
      end

      def extract_each_from(source_code)
        if block_given?
          each_function_call(source_code) do |node|
            if valid_name?(node) && valid_args?(node)
              yield make_phrase(
                get_key(node)
              )
            end
          end
        else
          to_enum(__method__, source_code)
        end
      end

      protected

      def each_function_call(source_code)
        raise NotImplementedError, "#{__method__} must be implemented by derived classes."
      end

      def valid_name?(node)
        raise NotImplementedError, "#{__method__} must be implemented by derived classes."
      end

      def valid_args?(node)
        raise NotImplementedError, "#{__method__} must be implemented by derived classes."
      end

      def make_phrase(key, meta_key = nil, file = nil)
        Phrase.new(key, meta_key, file)
      end
    end

  end
end
