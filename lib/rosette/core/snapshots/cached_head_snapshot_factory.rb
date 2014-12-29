# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    # Takes head snapshots and caches the results. Take a look at
    # +ActiveSupport::Cache+ for a good set of cache stores that conform to the
    # right interface.
    #
    # @see http://api.rubyonrails.org/classes/ActiveSupport/Cache.html
    #
    # @!attribute [r] cache
    #   @return [#fetch] the cache store. This can be any object that responds
    #     to +#fetch+ (and passes a block).
    class CachedHeadSnapshotFactory < HeadSnapshotFactory
      attr_reader :cache

      # Creates a new cached head snapshot factory that uses the given cache.
      #
      # @param [#fetch] cache The cache to use.
      def initialize(cache)
        @cache = cache
      end

      protected

      def process_ref(rev_walk, ref)
        cache_key = head_snapshot_cache_key(
          repo_config.name,
          repo_config.repo.get_rev_commit(ref, rev_walk).getId.name
        )

        cache.fetch(cache_key) do
          super
        end
      end

      def head_snapshot_cache_key(repo_name, commit_id)
        ['head_snapshots', repo_config.name, commit_id].join('/')
      end

      def head_snapshot_factory
        Rosette::Core::HeadSnapshotFactory
      end

    end

  end
end
