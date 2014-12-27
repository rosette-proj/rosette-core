# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Takes a snapshot of a repository and returns the snapshot hash. Snapshots
      # are simple hashes that map file paths to git commit ids. The commit ids
      # indicate in which commit the corresponding file last changed.
      #
      # @!attribute [Array] paths
      #   @return [Array] the paths to consider when taking the snapshot. Any paths
      #     that do not exist in this array will not appear in the snapshot.
      class RepoSnapshotCommand < GitCommand
        attr_reader :paths

        include WithSnapshots
        include WithRepoName
        include WithRef

        # Set the paths that will be included in the snapshot.
        #
        # @param [Array] paths The paths to include in the snapshot.
        # @return [self]
        def set_paths(paths)
          @paths = paths
          self
        end

        # Take the snapshot.
        #
        # @return [Hash] the snapshot hash (file path to commit id pairs).
        def execute
          take_snapshot(get_repo(repo_name), commit_id, paths)
        end
      end

    end
  end
end
