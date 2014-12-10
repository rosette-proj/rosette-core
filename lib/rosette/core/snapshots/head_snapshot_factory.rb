# encoding: UTF-8

# java_import 'org.eclipse.jgit.revwalk.RevWalk'
# java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'
# java_import 'org.eclipse.jgit.treewalk.TreeWalk'
# java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.PathFilter'
# java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
# java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core

    class HeadSnapshotFactory
      include SnapshotFilterable

      attr_reader :repo

      def set_repo(repo)
        @repo = repo
      end

      def take_snapshot
      end
    end

  end
end
