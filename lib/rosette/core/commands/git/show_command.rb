# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'

module Rosette
  module Core
    module Commands

      # Show the phrases that were added, removed, or modified directly by
      # the given commit. Essentially this means a diff against the parent.
      #
      # @example
      #   cmd = ShowCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('my_branch')
      #
      #   cmd.execute
      #   # {
      #   #   added: [
      #   #     { key: 'Foo', ... },
      #   #   ],
      #   #   removed: [
      #   #     { key: 'I got deleted', ... }
      #   #   ],
      #   #   modified: [
      #   #     { key: 'New value', old_key: 'Old value', ... }
      #   #   ]
      #   # }
      class ShowCommand < DiffBaseCommand
        include WithRepoName
        include WithRef

        # Computes the show (i.e. parent diff).
        # @return [Hash] a hash of differences, grouped by added/removed/modified keys. Each
        #   value is an array of phrases. For added and removed phrases, the phrase hashes
        #   will contain normal phrase attributes. For changed phrases, the phrase hashes
        #   will contain normal phrase attributes plus a special +old_key+ attribute that
        #   contains the previous key of the phrase. See the example above for a visual
        #   representation of the diff hash.
        def execute
          rev_walker = RevWalk.new(repo_config.repo.jgit_repo)
          diff_finder = DiffFinder.new(repo_config.repo.jgit_repo, rev_walker)

          repo_config = get_repo(repo_name)
          repo = repo_config.repo
          diff = repo.ref_diff_with_parent(commit_id, finder)
          rev = repo.get_rev_commit(commit_id, rev_walker)
          parent_commit_ids = repo.parent_ids_of(rev)

          child_snapshot = {}
          child_paths = []

          diff.each do |diff_entry|
            path = diff_entry.getNewPath
            child_snapshot[path] = commit_id
            child_paths << (path == '/dev/null' ? diff_entry.getOldPath : path)
          end

          child_phrases = datastore.phrases_by_commits(repo_name, child_snapshot).to_a

          parent_phrases = parent_commit_ids.flat_map do |parent_commit_id|
            parent_snapshot = take_snapshot(repo_config, parent_commit_id, child_paths)
            ensure_commits_have_been_processed(parent_snapshot.values)
            datastore.phrases_by_commits(repo_name, parent_snapshot).to_a
          end

          diff = compare(child_phrases, parent_phrases)

          diff.each_with_object({}) do |(state, diff_entries), ret|
            ret[state] = diff_entries.select do |diff_entry|
              diff_entry.phrase.commit_id == commit_id || (
                diff_entry.state == :removed &&
                  parent_commit_ids.include?(diff_entry.phrase.commit_id)
              )
            end
          end
        end
      end

    end
  end
end
