# encoding: UTF-8

require 'thread'

java_import 'org.eclipse.jgit.api.BlameCommand'
java_import 'org.eclipse.jgit.api.CloneCommand'
java_import 'org.eclipse.jgit.api.FetchCommand'
java_import 'org.eclipse.jgit.api.Git'
java_import 'org.eclipse.jgit.diff.RawTextComparator'
java_import 'org.eclipse.jgit.internal.storage.file.FileRepository'
java_import 'org.eclipse.jgit.lib.Constants'
java_import 'org.eclipse.jgit.lib.ObjectId'
java_import 'org.eclipse.jgit.lib.RefDatabase'
java_import 'org.eclipse.jgit.revwalk.RevSort'
java_import 'org.eclipse.jgit.revwalk.RevWalk'

module Rosette
  module Core

    # Wraps a git repository and can perform operations on it via jgit.
    # NOTE: This class is NOT thread safe.
    #
    # @example
    #   repo = Repo.from_path('/path/to/my_repo/.git')
    #   repo.get_rev_commit('master')  # => <RevCommit #5234ab6>
    #
    # @!attribute [r] jgit_repo
    #   @return [Java::OrgEclipseJgitStorageFile::FileRepository] The jgit
    #     repository object.
    class Repo
      attr_reader :jgit_repo

      # Creates a repo instance from the given path.
      #
      # @param [String] path The path to the .git directory of a git
      #   repository.
      # @return [Repo] The new repo instance.
      def self.from_path(path)
        new(FileRepository.new(path))
      end

      # Creates a new repo instance from the given jgit repo object.
      #
      # @param [Java::OrgEclipseJgitStorageFile::FileRepository] jgit_repo
      #   The jgit repo object to wrap.
      def initialize(jgit_repo)
        @jgit_repo = jgit_repo
        @fetch_clone_mutex = Mutex.new
      end

      # Retrieves a jgit commit object for the given ref or commit id.
      #
      # @param [String] ref_or_commit_id The git ref (i.e. a branch name) or
      #   git commit id of the commit to retrieve.
      # @param [Java::OrgEclipseJgitRevwalk::RevWalk] walker The +RevWalk+ to
      #   use. Since +RevCommits+ returned from different +RevWalk+s aren't
      #   equivalent, callers may want to pass in an instance of their own.
      #   By default, an internally created +RevWalk+ is used.
      # @return [Java::OrgEclipseJgitRevwalk::RevCommit] The identified
      #   +RevCommit+.
      def get_rev_commit(ref_or_commit_id, walker = rev_walker)
        if ref = get_ref(ref_or_commit_id)
          walker.parseCommit(ref.getObjectId)
        else
          walker.parseCommit(
            ObjectId.fromString(ref_or_commit_id)
          )
        end
      end

      # Calculates a diff between two git refs or commit ids.
      #
      # @see DiffFinder
      # @param [String] ref_parent The parent git ref or commit id.
      # @param [String] ref_child The child git ref or commit id.
      # @param [Array<String>] paths The paths to include in the diff. If an
      #   empty array is given, returns a diff for all paths.
      # @return [Array<Java::OrgEclipseJgitDiff::DiffEntry>]
      def diff(ref_parent, ref_child, paths = [])
        diff_finder.diff(
          get_rev_commit(ref_parent),
          get_rev_commit(ref_child),
          paths
        )
      end

      # Calculates a diff for the given ref against its parent.
      #
      # @param [String] ref The ref to diff with.
      # @return [Array<Java::OrgEclipseJgitDiff::DiffEntry>]
      def ref_diff_with_parent(ref)
        rev_diff_with_parent(get_rev_commit(ref))
      end

      # Calculates a diff for the given rev against its parent.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev The rev to diff with.
      # @return [Array<Java::OrgEclipseJgitDiff::DiffEntry>]
      def rev_diff_with_parent(rev)
        diff_finder.diff_with_parent(rev)
      end

      # Retrieves the parent commits for the given rev.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev The rev to get
      #   parents for.
      # @return [Array<Java::OrgEclipseJgitRevwalk::RevCommit>] A list of
      #   parent commits.
      def parents_of(rev)
        rev.getParentCount.times.map do |i|
          rev.getParent(i)
        end
      end

      # Retrieves the parent commit ids for the given rev.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev The rev to get
      #   parent ids for.
      # @return [Array<Java::OrgEclipseJgitLib::ObjectId>] An array of object
      #   id instances (the commit ids for the parents of +rev+).
      def parent_ids_of(rev)
        parents_of(rev).map { |parent| parent.getName }
      end

      # Retrieves the path for the repository's working directory.
      #
      # @return [String] The path to the working directory.
      def path
        jgit_repo.workTree.path
      end

      # Reads the git entry for the given object id and returns the bytes.
      #
      # @param [Java::OrgEclipseJgitLib::ObjectId] object_id The object id
      #   to retrieve bytes for.
      # @return [Array<Fixnum>] An array of bytes.
      def read_object_bytes(object_id)
        object_reader.open(object_id).getBytes
      end

      # Iterates over and yields each commit in the repo.
      #
      # @return [void, Enumerator] If no block is given, returns an
      #   +Enumerator+.
      # @yield [rev]
      # @yieldparam rev [Java::OrgEclipseJgitRevwalk::RevCommit]
      def each_commit
        if block_given?
          commit_walker = RevWalk.new(jgit_repo).tap do |walker|
            walker.markStart(all_heads(walker))
            walker.sort(RevSort::REVERSE)
          end

          commit_walker.each { |cur_rev| yield cur_rev }
          commit_walker.dispose
        else
          to_enum(__method__)
        end
      end

      # Iterates over and yields each commit, starting at the given git ref
      # or commit id.
      #
      # @param [String] start_ref The ref to start at.
      # @return [void, Enumerator] If no block is given, returns an
      #   +Enumerator+.
      def each_commit_starting_at(start_ref)
        if block_given?
          commit_walker = RevWalk.new(jgit_repo).tap do |walker|
            walker.markStart(get_rev_commit(start_ref, walker))
          end

          commit_walker.each { |cur_rev| yield cur_rev }
          commit_walker.dispose
        else
          to_enum(__method__, start_ref)
        end
      end

      # Iterates over and yields each commit, starting at the given git ref
      # or commit id and ending at the other.
      #
      # @param [String] start_ref The beginning of the commit range.
      # @param [String] end_ref The end of the commit range (inclusive).
      # @return [void, Enumerator] If no block is given, returns an
      #   +Enumerator+.
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

      # Counts the number of commits in the repo.
      #
      # @return [Fixnum] The number of commits in the repo.
      def commit_count
        commit_walker = RevWalk.new(jgit_repo).tap do |walker|
          walker.markStart(all_heads(walker))
        end

        count = commit_walker.count
        commit_walker.dispose
        count
      end

      # Fetches the repository.
      #
      # @param [String] remote The remote to fetch from.
      # @return [void]
      def fetch(remote = 'origin')
        @fetch_clone_mutex.synchronize do
          git.fetch.setRemote(remote).call
        end
      end

      # Clones a repository
      #
      # @param [String] repo_uri The URI of the repo to be cloned.
      # @param [String] repo_dir The directory to store the local copy.
      # @return [void]
      def self.clone(repo_uri, repo_dir)
        @fetch_clone_mutex.synchronize do
          CloneCommand.new
            .setDirectory(Java::JavaIo::File.new(repo_dir))
            .setURI(repo_uri)
            .call
        end
      end

      # Retrieves the first non-merge parent of the given ref or commit id.
      #
      # @param [String] ref The git ref or commit id.
      # @return [Java::OrgEclipseJgitRevwalk::RevCommit] The first non-merge
      #   parent of +ref+.
      def find_first_non_merge_parent(ref)
        each_commit_starting_at(ref).with_index do |prev_rev, idx|
          next if idx == 0
          break prev_rev if prev_rev.getParentCount <= 1
        end
      end

      # Finds git authors per source line for the given file and commit.
      #
      # @param [String] path The file path.
      # @param [String] commit_id The commit id.
      # @return [Hash<Fixnum, Java::OrgEclipseJgitLib::PersonIdent>]
      #   A hash of line numbers to git authors.
      def blame(path, commit_id)
        blame_result = BlameCommand.new(jgit_repo)
          .setFilePath(path)
          .setFollowFileRenames(true)
          .setTextComparator(RawTextComparator::WS_IGNORE_ALL)
          .setStartCommit(ObjectId.fromString(commit_id))
          .call

        lines_to_authors = {}
        line_number = 0

        loop do
          begin
            lines_to_authors[line_number] = blame_result.getSourceAuthor(line_number)
            line_number += 1
          rescue Java::JavaLang::ArrayIndexOutOfBoundsException
            break
          end
        end

        lines_to_authors
      end

      # Gets a reference to the given git ref.
      #
      # @param [String] ref_str The ref to get.
      # @return [Java::OrgEclipseJgitLib::Ref] A reference to the commit found
      #   for +ref_str+.
      def get_ref(ref_str)
        jgit_repo.getRef(ref_str)
      end

      # Get all refs in the repo.
      #
      # @return [Hash<String, Java::OrgEclipseJgitLib::Ref>] A hash of ref
      #   strings to jgit ref objects.
      def all_refs
        jgit_repo.all_refs
      end

      # Get all head refs in the repo.
      #
      # @return [Array<String>] A list of all head refs.
      def all_head_refs
        all_refs = jgit_repo.refDatabase.getRefs(RefDatabase::ALL).keys
        all_refs.select do |ref|
          ref =~ /\Arefs\/(?:heads|remotes)/
        end
      end

      # Get a list of commits for all the heads in the repo.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevWalk] walker The walker to use.
      # @return [Array<Java::OrgEclipseJgitRevwalk::RevCommit>] A list of
      #   commits, one for each of the heads in the repo.
      def all_heads(walker = rev_walker)
        all_head_refs.map { |ref| get_rev_commit(ref, walker) }
      end

      private

      def git
        @git ||= Git.new(jgit_repo)
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
