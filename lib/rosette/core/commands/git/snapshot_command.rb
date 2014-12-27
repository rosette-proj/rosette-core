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
      class SnapshotCommand < GitCommand
        include WithSnapshots
        include WithRepoName
        include WithRef

        # Take the snapshot.
        #
        # @return [Array<Rosette::Core::Phrase>] the list of phrases from the
        #   snapshot.
        def execute
          snapshot = take_snapshot(get_repo(repo_name), commit_id)
          datastore.phrases_by_commits(repo_name, snapshot).to_a
        end
      end

    end
  end
end
