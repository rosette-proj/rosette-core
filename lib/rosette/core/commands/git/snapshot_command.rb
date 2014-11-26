# encoding: UTF-8

module Rosette
  module Core
    module Commands

      class SnapshotCommand < GitCommand
        include WithSnapshots
        include WithRepoName
        include WithRef

        def execute
          snapshot = take_snapshot(get_repo(repo_name), commit_id)
          datastore.phrases_by_commits(repo_name, snapshot).to_a
        end
      end

    end
  end
end