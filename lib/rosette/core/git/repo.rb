# encoding: UTF-8

require 'thread'

java_import 'org.eclipse.jgit.api.CloneCommand'
java_import 'org.eclipse.jgit.api.FetchCommand'
java_import 'org.eclipse.jgit.api.Git'
java_import 'org.eclipse.jgit.internal.storage.file.FileRepository'
java_import 'org.eclipse.jgit.lib.Constants'
java_import 'org.eclipse.jgit.lib.ObjectId'
java_import 'org.eclipse.jgit.lib.RefDatabase'
java_import 'org.eclipse.jgit.revwalk.RevSort'
java_import 'org.eclipse.jgit.revwalk.RevWalk'

module Rosette
  module Core
    class Repo

      attr_reader :jgit_repo, :path

      def self.from_path(path)
        new(FileRepository.new(path))
      end

      def initialize(jgit_repo)
        @jgit_repo = jgit_repo
        @fetch_clone_mutex = Mutex.new
      end

      def get_rev_commit(ref_str_or_commit_id_str, walker = rev_walker)
        if ref = get_ref(ref_str_or_commit_id_str)
          walker.parseCommit(ref.getObjectId)
        else
          walker.parseCommit(
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
        parents_of(rev).map { |parent| parent.getName }
      end

      def path
        jgit_repo.workTree.path
      end

      def read_object_bytes(object_id)
        object_reader.open(object_id).getBytes
      end

      def each_commit
        if block_given?
          commit_walker = RevWalk.new(jgit_repo).tap do |walker|
            walker.markStart(all_heads)
            walker.sort(RevSort::REVERSE)
          end

          commit_walker.each { |cur_rev| yield cur_rev }
          commit_walker.dispose
        else
          to_enum(__method__)
        end
      end

      def each_commit_starting_at(start_ref)
        if block_given?
          commit_walker = RevWalk.new(jgit_repo).tap do |walker|
            walker.markStart(get_rev_commit(start_ref, walker))
          end

          commit_walker.each { |cur_rev| yield cur_rev }
          commit_walker.dispose
        else
          to_enum(__method__)
        end
      end

      def each_commit_in_range(start_ref, end_ref)
        if block_given?
          commit_walker = RevWalk.new(jgit_repo).tap do |walker|
            walker.markStart(get_rev_commit(start_ref, walker))
          end

          end_rev = get_rev_commit(end_ref, commit_walker)

          commit_walker.each do |cur_rev|
            yield cur_rev
            break if cur_rev.getId.name == end_rev.getId.name
          end

          commit_walker.dispose
        else
          to_enum(__method__, start_ref, end_ref)
        end
      end

      def commit_count
        commit_walker = RevWalk.new(jgit_repo).tap do |walker|
          walker.markStart(all_heads)
        end

        count = commit_walker.count
        commit_walker.dispose
        count
      end

      def fetch(remote = 'origin')
        @fetch_clone_mutex.synchronize do
          git.fetch.setRemote(remote).call
        end
      end

      def self.clone(repo_uri, repo_dir)
        @fetch_clone_mutex.synchronize do
          CloneCommand.new
            .setDirectory(Java::JavaIo::File.new(repo_dir))
            .setURI(repo_uri)
            .call
        end
      end

      def find_first_non_merge_parent(commit_id)
        each_commit_starting_at(commit_id) do |prev_rev|
          break prev_rev if prev_rev.getParentCount == 1
        end
      end

      private

      def git
        @git ||= Git.new(jgit_repo)
      end

      def all_heads
        all_refs = jgit_repo.refDatabase.getRefs(RefDatabase::ALL).keys

        refs = all_refs.select do |ref|
          ref =~ /\Arefs\/(?:heads|remotes)/
        end

        refs.map { |ref| get_rev_commit(ref) }
      end

      def get_ref(ref_str)
        jgit_repo.getRef(ref_str)
      end

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
