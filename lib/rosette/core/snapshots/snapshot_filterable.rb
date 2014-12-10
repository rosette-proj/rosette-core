# encoding: UTF-8

java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'

module Rosette
  module Core
    module SnapshotFilterable
      attr_reader :filters, :filter_strategy

      DEFAULT_FILTER_STRATEGY = :or
      AVAILABLE_FILTER_STRATEGIES = [:and, :or]

      def set_filter_strategy(strategy)
        if AVAILABLE_FILTER_STRATEGIES.include?(strategy)
          @filter_strategy = strategy
          self
        else
          raise ArgumentError, "'#{strategy}' is not a valid filter strategy."
        end
      end

      def add_filter(filter)
        filters << filter
        self
      end

      def filter_by_extensions(extensions)
        add_filter(FileTypeFilter.create(extensions))
        self
      end

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
