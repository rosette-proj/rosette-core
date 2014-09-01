# encoding: UTF-8

module Rosette
  module Core

    # parses "test" code by splitting the file into lines
    class TestExtractor < Extractor
      protected

      def each_function_call(source_code, &block)
        source_code.split("\n").each(&block)
      end

      def valid_name?(node)
        true
      end

      def valid_args?(node)
        true
      end
    end

  end
end
