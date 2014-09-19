# encoding: UTF-8

module Rosette
  module Core

    # Base class for extractors that extract entries from flat files,
    # eg. XML, YAML, json, etc.
    class StaticExtractor
      attr_reader :config

      def initialize(config = nil)
        @config = config
      end

      def extract_each_from(file_contents)
        raise NotImplementedError, "#{__method__} must be implemented by derived classes."
      end

      protected

      def make_phrase(key, meta_key = nil, file = nil)
        Phrase.new(key, meta_key, file)
      end
    end

  end
end
