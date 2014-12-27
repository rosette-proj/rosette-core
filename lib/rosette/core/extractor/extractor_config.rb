# encoding: UTF-8

module Rosette
  module Core

    # Configuration for an extractor.
    #
    # @example
    #   ex = ExtractorConfig.new(JsonExtractor::KeyValueExtractor)
    #     .set_encoding(Encoding::UTF_8)
    #     .set_conditions do |root|
    #       root.match_file_extension('.json').and(
    #         root.match_path('config/locales')
    #       )
    #     end
    #
    # @!attribute [r] extractor
    #   @return [Extractor] the extractor instance that will be used to
    #     extract phrases.
    # @!attribute [r] encoding
    #   @return [String, Encoding] the encoding to expect the contents of
    #     source files to be in.
    # @!attribute [r] root
    #   @return [ExtractorConfigurationFactory::Node] the root of the
    #     conditions tree. Only files that are matched by the conditions in
    #     this tree will have their phrases extracted.
    class ExtractorConfig
      attr_reader :extractor, :encoding, :root

      # Creates a new extractor configuration.
      #
      # @param [Class] extractor_class The extractor to use.
      def initialize(extractor_class)
        @extractor = extractor_class.new(self)
        @root = ExtractorConfigurationFactory.create_root
        @encoding = Rosette::Core::DEFAULT_ENCODING
      end

      # Sets the encoding to expect the contents of source files to be in.
      #
      # @param [String, Encoding] new_encoding the encoding to use.
      # @return [self]
      def set_encoding(new_encoding)
        @encoding = new_encoding
        self
      end

      # Determines if the given path matches all the conditions in the
      # conditions tree.
      #
      # @param [String] path The path to match.
      # @return [Boolean] true if the path matches, false otherwise.
      def matches?(path)
        root.matches?(path)
      end

      # Creates and yields a node that represents the root of a conditions
      # tree. Callers should use the yielded root to build up a set of
      # conditions that will be used to match paths in the repository.
      # Matching paths will be processed by the extractor (i.e. their
      # translatable phrases will be identified and stored).
      #
      # @return [self]
      # @yield [root] the root of the conditions tree
      # @yieldparam root [ExtractorConfigurationFactory::Node]
      def set_conditions
        @root = yield ExtractorConfigurationFactory.create_root
        self
      end
    end

    # Constructs condition trees for extractor configs.
    #
    # @see ExtractorConfig
    class ExtractorConfigurationFactory
      # Creates a new empty node that can be used as the root of a
      # conditions tree.
      #
      # @return [Node] the new empty node
      def self.create_root
        Node.new
      end

      # Facilitates creating operator nodes that can perform binary
      # operations, like "and", "or", and "not".
      module NodeOperatorFactory
        # Creates an {OrNode} for combining two nodes together with a
        # logical "or".
        #
        # @param [Node] right The other node. The left node is +self+.
        # @return [OrNode] a node representing the logical "or" of +self+
        #   and +right+.
        def or(right)
          OrNode.new(self, right)
        end

        # Creates an {AndNode} for combining two nodes together with a
        # logical "and".
        #
        # @param [Node] right The other node. The left node is +self+.
        # @return [AndNode] a node representing the logical "and" of +self+
        #   and +right+.
        def and(right)
          AndNode.new(self, right)
        end

        # Creates a {NotNode} for negating +self+.
        #
        # @return [NotNode] a node representing the negation of +self+.
        def not
          NotNode.new(self)
        end
      end

      # Provides common methods for creating nodes.
      module NodeFactory
        # Creates a {FileExtensionNode}.
        #
        # @param [String] extension The file extension to match.
        # @return [FileExtensionNode]
        def match_file_extension(extension)
          FileExtensionNode.new(extension)
        end

        # Creates a bunch of {FileExtensionNode}s combined using a logical "or".
        #
        # @param [Array<String>] extensions A list of file extensions.
        # @return [FileExtensionNode, OrNode] the root node of a tree of all
        #   the file extensions specified in +extensions+. Each file extension
        #   will be wrapped in a {FileExtensionNode} and logically "or"ed
        #   together. If +extensions+ only contains one file extension, then this
        #   method just returns an instance of {FileExtensionNode}. If +extensions+
        #   contains more than one entry, this method returns an {OrNode}.
        def match_file_extensions(extensions)
          Array(extensions).inject(nil) do |node, extension|
            new_node = match_file_extension(extension)
            node ? node.or(new_node) : new_node
          end
        end

        # Creates a {PathNode}.
        #
        # @param [String] path The path to match.
        # @return [PathNode]
        def match_path(path)
          PathNode.new(path)
        end

        # Creates a bunch of {PathNode}s combined using a logical "or".
        #
        # @param [Array<String>] A list of paths.
        # @return [PathNode, OrNode] the root of a tree of all the paths specified
        #   in +paths+. Each path will be wrapped in a {PathNode} and logically
        #   "or"ed together. If +paths+ only contains one path, then this method
        #   just returns an instance of {PathNode}. If +paths+ contains more than
        #   one entry, this method returns an {OrNode}.
        def match_paths(paths)
          Array(paths).inject(nil) do |node, path|
            new_node = match_path(path)
            node ? node.or(new_node) : new_node
          end
        end

        # Creates a {RegexNode}.
        #
        # @param [Regexp] regex The regex to match.
        # @return [RegexNode]
        def match_regex(regex)
          RegexNode.new(regex)
        end

        # Creates a bunch of {RegexNodes} combined using a logical "or".
        #
        # @param [Array<Regexp>] A list of regular expressions.
        # @return [RegexNode, OrNode] the root of a tree of all the regexes specified
        #   in +regexes+. Each regex will be wrapped in a {RegexNode} and logically
        #   "or"ed together. If +regexes+ only contains one entry, then this method
        #   just returns an instance of {RegexNode}. If +regexes+ contains more than
        #   one entry, this method returns an {OrNode}.
        def match_regexes(regexes)
          Array(regexes).inject(nil) do |node, regex|
            new_node = match_regex(regex)
            node ? node.or(new_node) : new_node
          end
        end
      end

      include NodeFactory

      # The base class for all condition nodes.
      class Node
        include NodeFactory
        include NodeOperatorFactory

        # Determines if the given path matches the conditions defined by this node
        # and it's children.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if +path+ matches, false otherwise.
        def matches?(path)
          false
        end
      end

      # The base class for all nodes that perform binary operations (i.e.
      # operations that take two operands).
      #
      # @!attribute [r] left
      #   @return [Node] the left child.
      # @!attribute [r] right
      #   @return [Node] the right child.
      class BinaryNode < Node
        attr_reader :left, :right

        # Creates a new binary node with left and right children.
        #
        # @param [Node] left The left child.
        # @param [Node] right The right child.
        def initialize(left, right)
          @left = left
          @right = right
        end
      end

      # The base class for all nodes that perform unary operations (i.e.
      # operations that take only one operand).
      #
      # @!attribute [r] child
      #   @return [Node] the child node.
      class UnaryNode < Node
        attr_reader :child

        # Creates a new unary node.
        #
        # @param [Node] child The child.
        def initialize(child)
          @child = child
        end
      end

      # A logical "and".
      class AndNode < BinaryNode
        # Determines if the given path matches the left AND the right child's
        # conditions.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if both the left and right children match
        #   +path+, false otherwise.
        def matches?(path)
          left.matches?(path) && right.matches?(path)
        end

        def to_s
          "(#{left.to_s} AND #{right.to_s})"
        end
      end

      # A logical "OR".
      class OrNode < BinaryNode
        # Determines if the given path matches the left OR the right child's
        # conditions.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if the left or the right child matches +path+,
        #   false otherwise.
        def matches?(path)
          left.matches?(path) || right.matches?(path)
        end

        def to_s
          "(#{left.to_s} OR #{right.to_s})"
        end
      end

      # A logical "NOT".
      class NotNode < UnaryNode
        # Determines if the given path does NOT match the child's conditions.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if the child does not match +path+, false
        #   otherwise.
        def matches?(path)
          !child.matches?(path)
        end

        def to_s
          "(NOT #{child.to_s})"
        end
      end

      # Matches file extensions.
      #
      # @!attribute [r] extension
      #   @return [String] the extension to match.
      class FileExtensionNode < Node
        attr_reader :extension

        # Creates a new file extension node.
        #
        # @param [String] extension The extension to match.
        def initialize(extension)
          @extension = extension
        end

        # Determines if the given path's file extension matches +extension+.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if the path matches +extension+, false otherwise.
        def matches?(path)
          # avoid using File.extname to allow matching against double extensions,
          # eg. file.html.erb
          path[-extension.size..-1] == extension
        end

        def to_s
          "has_file_extension('#{extension}')"
        end
      end

      # Matches paths.
      #
      # @!attribute [r] path
      #   @return [String] the path to match.
      class PathNode < Node
        attr_reader :path

        # Creates a new path node.
        #
        # @param [String] path The path to match.
        def initialize(path)
          @path = path
        end

        # Determines if the given path matches +path+.
        #
        # @param [String] match_path The path to match.
        # @return [Boolean] true if +match_path+ matches +path+, false otherwise.
        #   Matching is done by comparing the first +n+ characters of +match_path+
        #   to +path+, where +n+ is the number of characters in +path+. In other words,
        #   if +path+ is "/path/to" and +match_path+ is '/path/to/foo.rb', this method
        #   will return true.
        def matches?(match_path)
          match_path[0...path.size] == path
        end

        def to_s
          "matches_path('#{path}')"
        end
      end

      # Determines if the given path matches +regex+.
      #
      # @!attribute [r] regex
      #   @return [Regex] The regex to match with.
      class RegexNode < Node
        attr_reader :regex

        # Creates a new regex node.
        #
        # @param [Regex] regex The regex to match with.
        def initialize(regex)
          @regex = regex
        end

        # Determines if +regex+ matches the given path.
        #
        # @param [String] path The path to match.
        # @return [Boolean] true if +regex+ matches +path+, false otherwise.
        def matches?(path)
          !!(path =~ regex)
        end

        def to_s
          "matches_regex(/#{regex.source}/)"
        end
      end
    end

  end
end
