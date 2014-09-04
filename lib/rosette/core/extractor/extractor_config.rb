# encoding: UTF-8

module Rosette
  module Core

    class ExtractorConfig
      attr_reader :extractor, :encoding, :root

      def initialize(extractor_class, root)
        @extractor = extractor_class.new(self)
        @root = root
        @encoding = Rosette::Core::DEFAULT_ENCODING
      end

      def set_encoding(new_encoding)
        @encoding = new_encoding
        self
      end

      def matches?(path)
        root.matches?(path)
      end
    end

    class ExtractorConfigurationFactory
      def self.create_root
        Node.new
      end

      module NodeOperatorFactory
        def or(right)
          OrNode.new(self, right)
        end

        def and(right)
          AndNode.new(self, right)
        end

        def not
          NotNode.new(self)
        end
      end

      module NodeFactory
        def match_file_extension(extension)
          FileExtensionNode.new(extension)
        end

        def match_file_extensions(extensions)
          Array(extensions).inject(nil) do |node, extension|
            new_node = match_file_extension(extension)
            node ? node.or(new_node) : new_node
          end
        end

        def match_path(path)
          PathNode.new(path)
        end

        def match_paths(paths)
          Array(paths).inject(nil) do |node, path|
            new_node = match_path(path)
            node ? node.or(new_node) : new_node
          end
        end

        def match_regex(regex)
          RegexNode.new(regex)
        end

        def match_regexes(regexes)
          Array(regexes).inject(nil) do |node, regex|
            new_node = match_regex(regex)
            node ? node.or(new_node) : new_node
          end
        end
      end

      include NodeFactory

      class Node
        include NodeFactory
        include NodeOperatorFactory

        def matches?(path)
          false
        end
      end

      class BinaryNode < Node
        attr_reader :left, :right

        def initialize(left, right)
          @left = left
          @right = right
        end
      end

      class UnaryNode < Node
        attr_reader :child

        def initialize(child)
          @child = child
        end
      end

      class AndNode < BinaryNode
        def matches?(path)
          left.matches?(path) && right.matches?(path)
        end
      end

      class OrNode < BinaryNode
        def matches?(path)
          left.matches?(path) || right.matches?(path)
        end
      end

      class NotNode < UnaryNode
        def matches?(path)
          !child.matches?(path)
        end
      end

      class FileExtensionNode < Node
        attr_reader :extension

        def initialize(extension)
          @extension = extension
        end

        def matches?(path)
          # avoid using File.extname to allow matching against double extensions,
          # eg. file.html.erb
          path[-extension.size..-1] == extension
        end
      end

      class PathNode < Node
        attr_reader :path

        def initialize(path)
          @path = path
        end

        def matches?(match_path)
          match_path[0...path.size] == path
        end
      end

      class RegexNode < Node
        attr_reader :regex

        def initialize(regex)
          @regex = regex
        end

        def matches?(path)
          path =~ regex
        end
      end
    end

  end
end
