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
          parent_commit_ids = build_parent_commit_list
          phrase_diff = diff_between(commit_id, parent_commit_ids)
          filter_phrase_diff(commit_id, parent_commit_ids, phrase_diff)
        end

        protected

        def filter_phrase_diff(commit_id, parent_commit_ids, phrase_diff)
          phrase_diff.each_with_object({}) do |(state, diff_entries), ret|
            ret[state] = diff_entries.select do |diff_entry|
              diff_entry.phrase.commit_id == commit_id ||
                diff_entry.state == :removed
            end
          end
        end

        def build_parent_commit_list
          repo.parents_of(repo.get_rev_commit(commit_id)).map do |parent|
            if strict?
              parent.getId.name
            else
              get_closest_processed_parent(parent.getId.name)
            end
          end
        end
      end

    end
  end
end
