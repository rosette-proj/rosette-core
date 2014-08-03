# encoding: UTF-8

java_import 'org.eclipse.jgit.internal.storage.file.FileRepository'
java_import 'org.eclipse.jgit.lib.Constants'
java_import 'org.eclipse.jgit.lib.ObjectId'
java_import 'org.eclipse.jgit.revwalk.RevWalk'

module Rosette
  module Core
    class Repo

      attr_reader :jgit_repo

      def self.from_path(path)
        new(FileRepository.new(path))
      end

      def initialize(jgit_repo)
        @jgit_repo = jgit_repo
      end

      def get_ref(ref_str)
        jgit_repo.getRef(ref_str)
      end

      def get_rev_commit(ref_str_or_commit_id_str)
        if ref = get_ref(ref_str_or_commit_id_str)
          rev_walker.parseCommit(ref.getObjectId)
        else
          rev_walker.parseCommit(
            ObjectId.fromString(ref_str_or_commit_id_str)
          )
        end
      end

      def diff(ref_parent, ref_child, paths = [])
        diff_finder.diff(
          get_rev_commit(ref_parent),
          get_rev_commit(ref_child),
          paths
        )
      end

      def ref_diff_with_parent(ref)
        rev_diff_with_parent(get_rev_commit(ref))
      end

      def rev_diff_with_parent(rev)
        diff_finder.diff_with_parent(rev)
      end

      def parents_of(rev)
        rev.getParentCount.times.map do |i|
          rev.getParent(i)
        end
      end

      def parent_ids_of(rev)
        parents_of(rev).map { |parent| parent.getId.name }
      end

      def path
        jgit_repo.workTree.path
      end

      def read_object_bytes(object_id)
        object_reader.open(object_id).getBytes
      end

      private

      def diff_finder
        @diff_finder ||= DiffFinder.new(jgit_repo, rev_walker)
      end

      def rev_walker
        @rev_walker ||= RevWalk.new(jgit_repo)
      end

      def object_reader
        @object_reader ||= jgit_repo.newObjectReader
      end

    end
  end
end