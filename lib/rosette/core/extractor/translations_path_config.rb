# encoding: UTF-8

module Rosette
  module Core

    # Configuration for matching translation paths.
    #
    # @example
    #   ex = TranslationsPathConfig.new
    #     .set_conditions do |root|
    #       root.match_file_extension('.json').and(
    #         root.match_path('config/locales')
    #       )
    #     end
    #
    # @!attribute [r] root
    #   @return [PathMatcherFactory::Node] the root of the
    #     conditions tree. Only files that are matched by the conditions in
    #     this tree will be considered as translation paths.
    class TranslationsPathConfig
      attr_reader :root

      # Creates a new translation path matcher configuration.
      def initialize
        @root = PathMatcherFactory.create_root
      end

      # Sets the encoding to expect the contents of source files to be in.
      #
      # @param [String, Encoding] new_encoding the encoding to use.
      # @return [self]
      def set_encoding(new_encoding)
        tap { @encoding = new_encoding }
      end

      def locale_from_path(&block)
        tap { @locale_from_path_proc = block }
      end

      # Creates and yields a node that represents the root of a conditions
      # tree. Callers should use the yielded root to build up a set of
      # conditions that will be used to match paths in the repository.
      #
      # @return [self]
      # @yield [root] the root of the conditions tree
      # @yieldparam root [PathMatcherFactory::Node]
      def set_conditions
        tap { @root = yield root }
      end

      # Determines if the given path matches all the conditions in the
      # conditions tree.
      #
      # @param [String] path The path to match.
      # @return [Boolean] true if the path matches, false otherwise.
      def matches?(path)
        root.matches?(path)
      end

      def deduce_locale_from_path(path)
        @locale_from_path_proc.call(path)
      end
    end
  end
end
