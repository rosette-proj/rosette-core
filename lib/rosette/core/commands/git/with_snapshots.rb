# encoding: UTF-8

module Rosette
  module Core
    module Commands

      module WithSnapshots
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
