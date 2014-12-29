# encoding: UTF-8

module Rosette
  module Core

    # Base class for extractors that extract phrases from source code,
    # eg. Ruby, JavaScript, HAML, etc.
    #
    # @!attribute [r] config
    #   @return [Configurator] the Rosette config to use.
    class Extractor
      attr_reader :config

      # Creates a new extractor.
      #
      # @param [Configurator] config The Rosette config to use.
      def initialize(config = nil)
        @config = config
      end

      # Extracts each translatable phrase from the given source code.
      # Derived classes must implement the +#each_function_call+ method
      # for this to work.
      #
      # @param [String] source_code The source code to extract phrases
      #   from.
      # @return [void, Enumerator] If passed a block, this method yields
      #   each consecutive phrase found in +source_code+. If no block is
      #   passed, it returns an +Enumerator+.
      # @yield [phrase] a single extracted phrase.
      # @yieldparam phrase [Phrase]
      def extract_each_from(source_code)
        if block_given?
          each_function_call(source_code) do |node, line_number|
            if valid_name?(node) && valid_args?(node)
              yield make_phrase(get_key(node)), line_number
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

      def get_key(node)
        raise NotImplementedError, "#{__method__} must be implemented by derived classes."
      end

      def make_phrase(key, meta_key = nil, file = nil)
        Phrase.new(key, meta_key, file)
      end
    end

  end
end
