# encoding: UTF-8

module Rosette
  module Core
    module Commands

      class RepoSnapshotCommand < GitCommand
        attr_reader :paths

        include WithSnapshots
        include WithRepoName
        include WithRef

        def set_paths(paths)
          @paths = paths
        end

        def execute
          take_snapshot(get_repo(repo_name), commit_id, paths)
        end
      end

    end
  end
end
