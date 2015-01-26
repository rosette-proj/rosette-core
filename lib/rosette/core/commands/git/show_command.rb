# encoding: UTF-8

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
          repo_config = get_repo(repo_name)

          repo = repo_config.repo
          rev = repo.get_rev_commit(commit_id)
          parent_commit_ids = repo.parent_ids_of(rev)

          child_snapshot = take_snapshot(repo_config, commit_id)
          child_phrases = datastore.phrases_by_commits(repo_name, child_snapshot).to_a

          parent_phrases = parent_commit_ids.flat_map do |parent_commit_id|
            datastore.phrases_by_commits(repo_name, take_snapshot(repo_config, parent_commit_id)).to_a
          end

          compare(child_phrases, parent_phrases)
        end
      end

    end
  end
end
