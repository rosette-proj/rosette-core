# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    class CachedHeadSnapshotFactory < HeadSnapshotFactory
      attr_reader :cache

      def initialize(cache)
        @cache = cache
      end

      protected

      def process_ref(rev_walk, ref)
        cache_key = head_snapshot_cache_key(
          repo_config.name,
          repo.get_rev_commit(ref, rev_walk).getId.name
        )

        cache.fetch(cache_key) do
          super
        end
      end

      def head_snapshot_cache_key(repo_name, commit_id)
        ['head_snapshots', repo_name, commit_id].join('/')
      end

      def head_snapshot_factory
        Rosette::Core::HeadSnapshotFactory
      end

    end

  end
end
