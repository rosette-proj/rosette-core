# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'
java_import 'org.eclipse.jgit.treewalk.EmptyTreeIterator'
java_import 'org.eclipse.jgit.treewalk.TreeWalk'
java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core

    # Takes snapshots of git repos. A snapshot is a simple key/value map (hash)
    # of paths to commit ids. The commit id is the last time the file changed.
    #
    # @example
    #   snapshot = SnapshotFactory.new
    #     .set_repo(Repo.from_path(...))
    #     .set_start_commit_id('73cd130a42017d794ffa86ef0d255541d518a7b3')
    #     .take_snapshot
    #
    # @!attribute [r] repo
    #   @return [Repo] the Rosette repo object to use.
    # @!attribute [r] start_commit_id
    #   @return [String] the git commit id to start at. File changes that
    #     occurred more recently than this commit will not be reflected in
    #     the snapshot.
    class SnapshotFactory
      include SnapshotFilterable

      attr_reader :repo, :start_commit_id

      # Creates a new factory.
      def initialize
        reset
      end

      # Sets the Rosette repo object to use.
      #
      # @param [Repo] repo The Rosette repo object to use.
      # @return [self]
      def set_repo(repo)
        @repo = repo
        self
      end

      # Sets the starting commit id. File changes that occurred more recently
      # than this commit will not be reflected in the snapshot. In other words,
      # this is the commit id to take the snapshot of.
      #
      # @param [String] commit_id The starting commit id.
      # @return [self]
      def set_start_commit_id(commit_id)
        @start_commit_id = commit_id
        self
      end

      # Takes the snapshot.
      #
      # @return [Hash<String, String>] The snapshot hash (path to commit id
      #   pairs).
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
          tree_filter = if path_hash.size > 0
            path_filter = PathFilterGroup.createFromStrings(path_hash.keys.select { |k| k.include?('en.yml') })
            AndTreeFilter.create(path_filter, TreeFilter::ANY_DIFF)
          end

          tree_walk = TreeWalk.new(repo.jgit_repo)
          rev_walk.markStart(rev_commit)

          while cur_commit = rev_walk.next
            cur_commit_id = cur_commit.getId.name

            tree_walk.reset
            parent_count = cur_commit.getParentCount

            if parent_count == 0
              tree_walk.addTree(EmptyTreeIterator.new)
            else
              parent_count.times do |i|
                tree_walk.addTree(cur_commit.getParent(i).getTree)
              end
            end

            tree_walk.addTree(cur_commit.getTree)
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
        path_gatherer = make_path_gatherer(rev_commit.getId.name)

        files = each_file_in(path_gatherer).each_with_object({}) do |walker, ret|
          ret[walker.getPathString] = nil
        end

        path_gatherer.release
        files
      end

      def make_path_gatherer(commit_id)
        rev_walk = RevWalk.new(repo.jgit_repo)
        rev_commit = repo.get_rev_commit(commit_id, rev_walk)

        tree_walk = TreeWalk.new(repo.jgit_repo).tap do |walker|
          walker.addTree(rev_commit.getTree)
          walker.setFilter(compile_filter)
          walker.setRecursive(true)
        end

        rev_walk.dispose
        tree_walk
      end

      def reset
        @repo = nil
        @start_commit_id = nil
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
