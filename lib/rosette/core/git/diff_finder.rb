# encoding: UTF-8

java_import 'org.eclipse.jgit.util.io.NullOutputStream'
java_import 'org.eclipse.jgit.diff.DiffFormatter'
java_import 'org.eclipse.jgit.treewalk.CanonicalTreeParser'
java_import 'org.eclipse.jgit.treewalk.EmptyTreeIterator'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'

module Rosette
  module Core

    # Used to compute diffs between two git refs. Can also read file
    # contents from diff entries.
    #
    # @!attribute [r] jgit_repo
    #   @return [Java::OrgEclipseJgitStorageFile::FileRepository] the git
    #     repository.
    # @!attribute [r] rev_walker
    #   @return [Java::OrgEclipseJgitRevwalk::RevWalk] the RevWalk instance
    #     to use.
    class DiffFinder
      attr_reader :jgit_repo, :rev_walker

      # Creates a new diff finder instance.
      #
      # @param [Java::OrgEclipseJgitStorageFile::FileRepository] jgit_repo
      #   The git repository.
      # @param [Java::OrgEclipseJgitRevwalk::RevWalk] rev_walker The RevWalk
      #   instance to use.
      def initialize(jgit_repo, rev_walker)
        @jgit_repo = jgit_repo
        @rev_walker = rev_walker
      end

      # Computes a diff between two revs.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev_parent The first
      #   commit to use in the diff (the parent).
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev_child The second
      #   commit to use in the diff (the child).
      # @param [Array<String>] paths The paths to include in the diff. If given
      #   an empty array, this method will return a diff for all paths.
      # @return [Array<Java::OrgEclipseJgitDiff::DiffEntry>] A list of diff
      #   entries for the diff between +rev_parent+ and +rev_child+. There will
      #   be one diff entry for each file that changed.
      def diff(rev_parent, rev_child, paths = [])
        diff_formatter.setPathFilter(construct_filter(Array(paths)))
        diff_formatter.scan(rev_parent.getTree, rev_child.getTree)
      end

      # Computes a diff between a rev and its parent.
      #
      # @param [Java::OrgEclipseJgitRevwalk::RevCommit] rev The rev to use.
      # @return [Array<Java::OrgEclipseJgitDiff::DiffEntry>] A list of diff
      #   entries for the diff between +rev+ and its parent. There will be
      #   one diff entry for each file that changed.
      def diff_with_parent(rev)
        if rev.getParentCount > 0
          rev.getParentCount.times.flat_map do |i|
            diff_formatter.scan(
              rev_walker.parseCommit(rev.getParent(i).getId).getTree,
              rev.getTree
            )
          end
        else
          diff_formatter.scan(
            EmptyTreeIterator.new,
            CanonicalTreeParser.new(
              nil, rev_walker.getObjectReader, rev.getTree
            )
          )
        end
      end

      # Reads the "new" contents of a diff entry. Diff entries contain a
      # reference to both the new and old files. The "new" contents means
      # the contents of the changed file, not the original.
      #
      # @param [Java::OrgEclipseJgitDiff::DiffEntry] entry The diff entry
      #   to read from.
      # @param [Encoding] encoding The encoding to expect the contents
      #   to be in.
      # @return [String] The file contents, encoded in +encoding+.
      def read_new_entry(entry, encoding = Encoding::UTF_8)
        Java::JavaLang::String.new(
          object_reader.open(entry.newId.toObjectId).getBytes, encoding.to_s
        )
      end

      private

      def object_reader
        @object_reader ||= jgit_repo.newObjectReader
      end

      def construct_filter(paths)
        paths = fix_paths(paths)
        PathFilterGroup.createFromStrings(paths) if paths.size > 0
      end

      def fix_paths(paths)
        # paths can't begin with a dot or dot slash (jgit limitation)
        paths.map do |path|
          path.gsub(/\A(\.(?:\/|\z))/, '')
        end.select do |path|
          !path.strip.empty?
        end
      end

      def diff_formatter
        @diff_formatter ||= DiffFormatter.new(NullOutputStream::INSTANCE).tap do |formatter|
          formatter.setRepository(jgit_repo)
        end
      end
    end

  end
end
