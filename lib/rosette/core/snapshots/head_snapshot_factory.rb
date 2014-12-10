# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'
# java_import 'org.eclipse.jgit.treewalk.TreeWalk'
# java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.PathFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
# java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core

    class HeadSnapshotFactory

      attr_reader :repo

      def set_repo(repo)
        @repo = repo
        self
      end

      def take_snapshot
        rev_walk = RevWalk.new(repo.jgit_repo)
        repo.all_head_refs.each_with_object({}) do |ref, snapshot|
          rev_walk.reset
          rev_walk.markStart(repo.get_rev_commit(ref, rev_walk))
          # rev_walk.setRevFilter(RevFilter::NO_MERGES)

          snapshot[ref] = if rev_commit = rev_walk.next
            rev_commit.getId.name
          end

        end

      end
    end

  end
end
