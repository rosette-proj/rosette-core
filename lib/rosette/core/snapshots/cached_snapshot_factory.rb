# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    class CachedSnapshotFactory
      attr_reader :cache

      def initialize(cache)
        @cache = cache
      end

      def take_snapshot(repo_config, commit_id, paths = [])
        paths = Array(paths)
        cache_key = snapshot_cache_key(repo_config.name, commit_id, paths)

        cache.fetch(cache_key) do
          rev = repo_config.repo.get_rev_commit(commit_id)

          factory = snapshot_factory.new
            .set_repo(repo_config.repo)
            .set_start_commit(rev)

          factory.filter_by_paths(paths) if paths.size > 0
          factory.take_snapshot
        end
      end

      private

      def snapshot_cache_key(repo_name, commit_id, paths)
        ['snapshots', repo_name, commit_id, path_digest(paths)].join('/')
      end

      def path_digest(paths)
        Digest::MD5.hexdigest(paths.join)
      end

      def snapshot_factory
        Rosette::Core::SnapshotFactory
      end
    end

  end
end
