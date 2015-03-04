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
    #   @return [PathMatcherFactory::Node] the root of the
    #     conditions tree. Only files that are matched by the conditions in
    #     this tree will have their phrases extracted.
    class ExtractorConfig
      attr_reader :extractor_id, :extractor, :encoding, :root

      # Creates a new extractor configuration.
      #
      # @param [String] extractor_id The extractor id of +extractor_class+.
      # @param [Class] extractor_class The extractor to use.
      def initialize(extractor_id, extractor_class)
        @extractor_id = extractor_id
        @extractor = extractor_class.new(self)
        @root = PathMatcherFactory.create_root
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
      # @yieldparam root [PathMatcherFactory::Node]
      def set_conditions
        @root = yield PathMatcherFactory.create_root
        self
      end
    end
  end
end
