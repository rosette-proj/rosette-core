# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.revwalk.filter.RevFilter'

module Rosette
  module Core

    # Takes a snapshot of all the repository's heads. A "head" snapshot is a
    # key/value map (hash) of git refs (i.e. branch names) to commit ids,
    # where the commit ids are the first non-merge commits for each branch.
    #
    # @example
    #   snapshot = HeadSnapshotFactory.new
    #     .set_repo_config(config)
    #     .take_snapshot
    #
    # @!attribute [r] repo_config
    #   @return [RepoConfig] the repo config that contains the repo to take
    #     the snapshot for.
    class HeadSnapshotFactory
      attr_reader :repo_config

      # Sets the repo config that contains the repo to take the snapshot for.
      #
      # @param [RepoConfig] repo_config
      # @return [self]
      def set_repo_config(repo_config)
        @repo_config = repo_config
        self
      end

      # Takes the snapshot.
      #
      # @return [Hash<String, String>] The head snapshot hash of refs to
      #   commit ids.
      def take_snapshot
        rev_walk = RevWalk.new(repo_config.repo.jgit_repo)
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
