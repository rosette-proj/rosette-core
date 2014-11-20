# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'
java_import 'org.eclipse.jgit.treewalk.TreeWalk'
java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core
    class SnapshotFactory

      DEFAULT_FILTER_STRATEGY = :or
      AVAILABLE_FILTER_STRATEGIES = [:and, :or]

      attr_reader :repo, :filters, :filter_strategy, :start_commit

      def initialize
        reset
      end

      def set_filter_strategy(strategy)
        if AVAILABLE_FILTER_STRATEGIES.include?(strategy)
          @filter_strategy = strategy
          self
        else
          raise ArgumentError, "'#{strategy}' is not a valid filter strategy."
        end
      end

      def set_repo(repo)
        @repo = repo
        self
      end

      def set_start_commit(commit)
        @start_commit = commit
        self
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

      def take_snapshot
        build_hash.tap do
          reset
        end
      end

      private

      def build_hash
        make_path_hash.tap do |path_hash|
          path_filter = PathFilterGroup.createFromStrings(path_hash.keys)
          tree_filter = AndTreeFilter.create(path_filter, TreeFilter::ANY_DIFF)
          tree_walk = TreeWalk.new(repo.jgit_repo)

          rev_walk = RevWalk.new(repo.jgit_repo)
          rev_walk.markStart(rev_walk.lookupCommit(start_commit.getId))
          rev_walk.setRevFilter(RevFilter::NO_MERGES)

          while cur_commit = rev_walk.next
            if cur_commit.getParentCount > 0
              cur_commit_id = cur_commit.getId.name

              tree_walk.reset
              tree_walk.addTree(cur_commit.getTree)
              tree_walk.addTree(cur_commit.getParent(0).getTree)
              tree_walk.setFilter(tree_filter)
              tree_walk.setRecursive(true)

              each_file_in(tree_walk) do |walker|
                path = walker.getPathString

                unless path_hash[path]
                  path_hash[path] = cur_commit_id
                end
              end
            end
          end

          rev_walk.dispose
          tree_walk.release
        end
      end

      def make_path_hash
        each_file_in(make_path_gatherer).each_with_object({}) do |walker, ret|
          ret[walker.getPathString] = nil
        end
      end

      def make_path_gatherer
        TreeWalk.new(repo.jgit_repo).tap do |walker|
          walker.addTree(start_commit.getTree)
          walker.setFilter(compile_filter)
          walker.setRecursive(true)
        end
      end

      def reset
        @repo = nil
        @filter_strategy = :or
        @filters = []
      end

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

      def each_file_in(tree_walk)
        if block_given?
          while tree_walk.next
            yield tree_walk
          end
        else
          to_enum(__method__, tree_walk)
        end
      end

    end
  end
end
