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

      attr_reader :repo_config

      def set_repo_config(repo_config)
        @repo_config = repo_config
        self
      end

      def take_snapshot
        rev_walk = RevWalk.new(repo_config.jgit_repo)
        repo_config.repo.all_head_refs.each_with_object({}) do |ref, snapshot|
          snapshot[ref] = process_ref(rev_walk, ref)
        end
      end

      protected

      def process_ref(rev_walk, ref)
        rev_walk.reset
        rev_walk.markStart(repo_config.repo.get_rev_commit(ref, rev_walk))
        rev_walk.setRevFilter(RevFilter::NO_MERGES)

        if rev_commit = rev_walk.next
          rev_commit.getId.name
        end
      end

    end

  end
end
