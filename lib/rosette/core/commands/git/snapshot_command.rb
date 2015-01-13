# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Takes a snapshot and returns a list of phrases. This is different from
      # {RepoSnapshotCommand} in that it doesn't return the snapshot hash itself,
      # but instead the phrases contained in the snapshot's commits.
      #
      # @example
      #   cmd = SnapshotCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #
      #   cmd.execute
      #   # => [<Phrase #ba012cd key: 'foobar'>, ...]
      #
      # @!attribute [Array] paths
      #   @return [Array] the paths to consider when taking the snapshot. Any paths
      #     that do not exist in this array will not appear in the snapshot.
      class SnapshotCommand < GitCommand
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
        # @return [Array<Rosette::Core::Phrase>] the list of phrases from the
        #   snapshot.
        def execute
          snapshot = take_snapshot(get_repo(repo_name), commit_id, paths)
          datastore.phrases_by_commits(repo_name, snapshot).to_a
        end
      end

    end
  end
end
