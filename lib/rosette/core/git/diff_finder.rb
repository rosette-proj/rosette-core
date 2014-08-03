# encoding: UTF-8

java_import 'org.eclipse.jgit.util.io.NullOutputStream'
java_import 'org.eclipse.jgit.diff.DiffFormatter'
java_import 'org.eclipse.jgit.treewalk.CanonicalTreeParser'
java_import 'org.eclipse.jgit.treewalk.EmptyTreeIterator'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'

module Rosette
  module Core

    class DiffFinder
      attr_reader :jgit_repo, :rev_walker

      def initialize(jgit_repo, rev_walker)
        @jgit_repo = jgit_repo
        @rev_walker = rev_walker
      end

      def diff(rev_parent, rev_child, paths = [])
        diff_formatter.setPathFilter(construct_filter(Array(paths)))
        diff_formatter.scan(rev_parent.getTree, rev_child.getTree)
      end

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

      private

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
