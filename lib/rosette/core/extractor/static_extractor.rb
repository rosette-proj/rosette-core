# encoding: UTF-8

module Rosette
  module Core

    # Base class for extractors that extract entries from flat files,
    # eg. XML, YAML, json, etc.
    #
    # @!attribute [r] config
    #   @return [Configurator] the Rosette config to use.
    class StaticExtractor
      attr_reader :config

      # Creates a new extractor.
      #
      # @param [Configurator] config The Rosette config to use.
      def initialize(config = nil)
        @config = config
      end

      # Extracts each translatable phrase from the given flat file
      # contents. Must be implemented by derived classes
      #
      # @param [String] file_contents The flat file contents to extract
      #   phrases from.
      # @return [nil, Enumerator] If passed a block, this method yields
      #   each consecutive phrase found in +file_contents+. If no block is
      #   passed, it returns an +Enumerator+.
      # @yield [phrase] a single extracted phrase.
      # @yieldparam phrase [Phrase]
      def extract_each_from(file_contents)
        raise NotImplementedError,
          "#{__method__} must be implemented by derived classes."
      end

      protected

      def make_phrase(key, meta_key = nil, file = nil)
        Phrase.new(key, meta_key, file)
      end
    end

  end
end
