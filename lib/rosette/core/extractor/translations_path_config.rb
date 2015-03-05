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

      # Provides a user-defined way of determining the locale a file is written
      # in. In a Rails app for example, config/locales/es.yml is written in the
      # "es" locale. If no block is given, this method does nothing.
      #
      # @param [Proc] block The block/proc that encapsulates the locale-deducing
      #   logic.
      # @return [self]
      def locale_from_path(&block)
        tap { @locale_from_path_proc = block if block_given? }
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

      # Figures out the locale a file is written in based on its path. For
      # example, in a Rails application, Spanish translations are stored in
      # config/locales/es.yml. In the case of Rails, each .yml file carries
      # the locale the file is written in, so this method would return "es".
      #
      # @param [String] path The path to examine.
      # @return [String] The locale detected in +path+.
      def deduce_locale_from_path(path)
        @locale_from_path_proc.call(path)
      end
    end
  end
end
