# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    # Takes snapshots and caches the results. Take a look at
    # +ActiveSupport::Cache+ for a good set of cache stores that conform to the
    # right interface.
    #
    # @see http://api.rubyonrails.org/classes/ActiveSupport/Cache.html
    #
    # @!attribute [r] cache
    #   @return [#fetch] the cache store. This can be any object that responds
    #     to +#fetch+ (and passes a block).
    class CachedSnapshotFactory
      attr_reader :cache

      # Creates a new cached snapshot factory that uses the given cache.
      #
      # @param [#fetch] cache The cache to use.
      def initialize(cache)
        @cache = cache
      end

      # Takes the snapshot.
      #
      # @param [RepoConfig] repo_config The repo config for the repo to take
      #   the snapshot for.
      # @param [String] commit_id The commit id to take the snapshot of.
      # @param [Array<String>] The list of paths to include in the snapshot.
      #   If +paths+ is empty, this method will return a snapshot that contains
      #   all paths.
      # @return [Hash<String, String>] The snapshot hash (path to commit id
      #   pairs).
      def take_snapshot(repo_config, commit_id, paths = [])
        paths = Array(paths)
        cache_key = snapshot_cache_key(repo_config.name, commit_id, paths)

        cache.fetch(cache_key) do
          factory = snapshot_factory.new
            .set_repo(repo_config.repo)
            .set_start_commit_id(commit_id)

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
