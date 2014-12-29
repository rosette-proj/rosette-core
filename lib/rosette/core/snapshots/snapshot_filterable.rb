# encoding: UTF-8

java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'

module Rosette
  module Core

    # Designed to be mixed into classes that take snapshots.
    #
    # @!attribute [r] filters
    #   @return [Array<Java::OrgEclipseJgitTreewalkFilter::TreeFilter>] A list
    #     of filters.
    # @!attribute [r] filter_strategy
    #   @return [Symbol] The current filter strategy (:and or :or).
    module SnapshotFilterable
      attr_reader :filters, :filter_strategy

      # The default filter combination strategy. Either :and or :or.
      DEFAULT_FILTER_STRATEGY = :or

      # A list of available filter strategies.
      AVAILABLE_FILTER_STRATEGIES = [:and, :or]

      # Sets the filter strategy to use when combining filters.
      #
      # @param [Symbol] strategy The filter strategy. Must be an entry inside
      #   {AVAILABLE_FILTER_STRATEGIES}.
      # @return [void]
      # @raise [ArgumentError] If +strategy+ is not a valid filter strategy.
      def set_filter_strategy(strategy)
        if AVAILABLE_FILTER_STRATEGIES.include?(strategy)
          @filter_strategy = strategy
          self
        else
          raise ArgumentError, "'#{strategy}' is not a valid filter strategy."
        end
      end

      # Adds a filter.
      #
      # @param [Java::OrgEclipseJgitTreewalkFilter::TreeFilter] filter The
      #   filter to add.
      # @return [self]
      def add_filter(filter)
        filters << filter
        self
      end

      # Adds a file extension filter (filters out any files that don't have
      # a matching file extension).
      #
      # @see FileTypeFilter
      #
      # @param [Array<String>] extensions The list of file extensions to
      #   filter by.
      # @return [self]
      def filter_by_extensions(extensions)
        add_filter(FileTypeFilter.create(extensions))
        self
      end

      # Adds a path filter (filters out any files that don't have a matching
      # path). In reality, this method adds a
      # +Java::OrgEclipseJgitTreewalkFilter::PathFilterGroup+ filter that is
      # capable of handling multiple paths.
      #
      # @param [Array<String>] paths The list of paths to filter by.
      # @return [self]
      def filter_by_paths(paths)
        add_filter(PathFilterGroup.createFromStrings(Array(paths)))
        self
      end

      protected

      def compile_filter
        if filters.size == 1
          filters.first
        elsif filters.size >= 2
          case filter_strategy
            when :or
              OrTreeFilter.create(filters)
            when :and
              AndTreeFilter.create(filters)
          end
        end
      end
    end
  end
end
