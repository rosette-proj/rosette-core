# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Mixin capable of taking snapshots of git repositories. Meant to be mixed
      # into the classes in {Rosette::Core::Commands}.
      #
      # @see Rosette::Core::SnapshotFactory
      #
      # @example
      #   class MyCommand < Rosette::Core::Commands::Command
      #     include WithSnapshots
      #   end
      #
      #   cmd = MyCommand.new
      #   snap = cmd.take_snapshot(repo_config, commit_id, paths)
      #   snap  # => { 'path/to/file.rb' => '67f0e9a60dfe39430b346086f965e6c94a8ddd24', ... }
      module WithSnapshots
        # Takes and returns a snapshot hash for the given repo and commit id. Limits
        # the paths returned via the +paths+ argument. If no paths are passed,
        # {#take_snapshot} returns a snapshot containing all the paths in the repository.
        #
        # @param [Rosette::Core::RepoConfig] repo_config The repository configuration
        #   to take the snapshot from.
        # @param [String] commit_id The git commit id to take the snapshot of.
        # @param [Array] paths The list of paths to consider when taking the snapshot.
        #   Only those paths included in this list will appear in the snapshot hash.
        # @return [Hash] the snapshot hash (path to commit id pairs).
        def take_snapshot(repo_config, commit_id, paths = [])
          __snapshot_factory__.take_snapshot(repo_config, commit_id, paths)
        end

        private

        def __snapshot_factory__
          @@__snapshot_factory__ ||=
            CachedSnapshotFactory.new(configuration.cache)
        end
      end

    end
  end
end
