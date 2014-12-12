# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'
java_import 'org.eclipse.jgit.treewalk.TreeWalk'
java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core
    class SnapshotFactory

      include SnapshotFilterable

      attr_reader :repo, :start_commit_id

      def initialize
        reset
      end

      def set_repo(repo)
        @repo = repo
        self
      end

      def set_start_commit_id(commit_id)
        @start_commit_id = commit_id
        self
      end

      def take_snapshot
        build_hash.tap do
          reset
        end
      end

      private

      def build_hash
        rev_walk = RevWalk.new(repo.jgit_repo)
        rev_commit = repo.get_rev_commit(start_commit_id, rev_walk)

        make_path_hash(rev_commit).tap do |path_hash|
          path_filter = PathFilterGroup.createFromStrings(path_hash.keys)
          tree_filter = AndTreeFilter.create(path_filter, TreeFilter::ANY_DIFF)
          tree_walk = TreeWalk.new(repo.jgit_repo)

          rev_walk.markStart(rev_commit)
          rev_walk.setRevFilter(RevFilter::NO_MERGES)

          while cur_commit = rev_walk.next
            cur_commit_id = cur_commit.getId.name

            tree_walk.reset
            tree_walk.addTree(cur_commit.getTree)

            if cur_commit.getParentCount > 0
              tree_walk.addTree(cur_commit.getParent(0).getTree)
            end

            tree_walk.setFilter(tree_filter)
            tree_walk.setRecursive(true)

            each_file_in(tree_walk) do |walker|
              path = walker.getPathString

              unless path_hash[path]
                path_hash[path] = cur_commit_id
              end
            end
          end

          rev_walk.dispose
          tree_walk.release
        end
      end

      def make_path_hash(rev_commit)
        each_file_in(make_path_gatherer(rev_commit)).each_with_object({}) do |walker, ret|
          ret[walker.getPathString] = nil
        end
      end

      def make_path_gatherer(rev_commit)
        TreeWalk.new(repo.jgit_repo).tap do |walker|
          walker.addTree(rev_commit.getTree)
          walker.setFilter(compile_filter)
          walker.setRecursive(true)
        end
      end

      def reset
        @repo = nil
        @filter_strategy = :or
        @filters = []
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
