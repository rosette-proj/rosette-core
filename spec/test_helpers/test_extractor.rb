# encoding: UTF-8

module Rosette
  module Extractors

    # parses "test" code by splitting the file into lines
    module Test
      class TestExtractor < Rosette::Core::Extractor
        def supports_line_numbers?
          true
        end

        protected

        def each_function_call(source_code)
          source_code.split("\n").each_with_index do |line, idx|
            yield line, idx
          end
        end

        def valid_name?(node)
          true
        end

        def valid_args?(node)
          true
        end

        def get_key(node)
          node.include?(':') ? node.split(':').last : node
        end

        def get_meta_key(node)
          node.include?(':') ? node.split(':').first : nil
        end
      end
    end

  end
end
