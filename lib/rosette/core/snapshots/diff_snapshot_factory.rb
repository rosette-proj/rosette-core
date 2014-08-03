# encoding: UTF-8

module Rosette
  module Core

    class DiffSnapshotFactory
      attr_reader :repo

      def initialize(repo)
        @repo = repo
      end

      def take_snapshot(head_ref, diff_point_ref)
        entries = repo.diff(head_ref, diff_point_ref)
        diff_point_paths = entries.map(&:getOldPath)
        head_paths = entries.map(&:getNewPath)

        head_snap = SnapshotFactory.new(repo, head_rev)
          .filter_by_paths(head_paths)
          .take_snapshot

        diff_point_snap = SnapshotFactory.new(repo, diff_point_rev)
          .filter_by_paths(diff_point_paths)
          .take_snapshot
      end
    end

  end
end