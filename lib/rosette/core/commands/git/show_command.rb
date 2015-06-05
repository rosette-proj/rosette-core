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

        attr_reader :strict
        alias_method :strict?, :strict

        def initialize(*args)
          super
          @strict = true
        end

        # Computes the show (i.e. parent diff).
        # @return [Hash] a hash of differences, grouped by added/removed/modified keys. Each
        #   value is an array of phrases. For added and removed phrases, the phrase hashes
        #   will contain normal phrase attributes. For changed phrases, the phrase hashes
        #   will contain normal phrase attributes plus a special +old_key+ attribute that
        #   contains the previous key of the phrase. See the example above for a visual
        #   representation of the diff hash.
        def execute
          parent_commit_ids = build_parent_commit_list

          # handle the case where this is the first commit (or there are no
          # processed parents)
          if parent_commit_ids.empty?
            entries = retrieve_child_phrases([]).map do |p|
              DiffEntry.new(p, :added)
            end

            { added: entries, removed: [], modified: [] }
          else
            phrase_diff = calculate_phrase_diff_against(parent_commit_ids)
            filter_phrase_diff(parent_commit_ids, phrase_diff)
          end
        end

        # Sets a boolean value that determines if the diff should be made
        # against true parents of the given commit or the most recently
        # processed parents. If set to +true+, the diff will be computed
        # between the given commit and its actual (true) parents, and an error
        # will be raised if any of the parents have not been processed by
        # Rosette (i.e. don't exist in the commit log). If set to +false+, the
        # diff will be computed between the given commit and the most recent
        # parents that have been processed. For each parent of the given commit,
        # +ShowCommand+ will traverse the commit history looking for a processed
        # commit and use it in place of the true parent (assuming the true
        # parent hasn't been processed yet). It's worth noting that setting
        # +strict+ to +false+ may potentially produce results that contain
        # phrases that were not introduced exclusively in the given commit.
        # Since such behavior is different from what git clients return, and
        # therefore possibly unexpected, strictness is enabled (set to +true+)
        # by default.
        #
        # @param [Boolean] strict
        # @return [self]
        def set_strict(strict)
          @strict = strict
          self
        end

        protected

        # if parent_commit_id is processed, it will get returned (i.e. it will
        # start looking at parent_commit_id, not parent_commit_id - 1).
        def get_closest_processed_parent(parent_commit_id)
          parent = repo.each_commit_starting_at(parent_commit_id).find do |rev|
            datastore.commit_log_exists?(repo_name, rev.getId.name)
          end

          parent.getId.name if parent
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

        def compute_git_diff_against(parent_commit_id)
          rev_walker = RevWalk.new(repo.jgit_repo)
          diff_finder = DiffFinder.new(repo.jgit_repo, rev_walker)
          repo.diff([parent_commit_id], commit_id, [], diff_finder)
        end

        def compute_paths(diff)
          child_paths = []

          diff.each_with_object([]) do |(_, diff_entries), ret|
            diff_entries.each do |diff_entry|
              path = diff_entry.getNewPath

              if repo_config.extractor_configs.any? { |ext| ext.matches?(path) }
                ret << get_path(diff_entry)
              end
            end
          end
        end

        def get_path(diff_entry)
          new_path = diff_entry.getNewPath

          if new_path == '/dev/null'
            diff_entry.getOldPath
          else
            new_path
          end
        end

        def retrieve_child_phrases(paths)
          snapshot = take_snapshot(repo_config, commit_id, paths)
          datastore.phrases_by_commits(repo_name, snapshot).to_a
        end

        def retrieve_parent_phrases(parent_commit_ids, paths)
          ensure_commits_have_been_processed(parent_commit_ids)

          parent_commit_ids.flat_map do |parent_commit_id|
            parent_snapshot = take_snapshot(
              repo_config, parent_commit_id, paths
            )

            datastore.phrases_by_commits(repo_name, parent_snapshot).to_a
          end
        end

        def calculate_phrase_diff_against(parent_commit_ids)
          { added: [], modified: [], removed: [] }.tap do |final_diff|
            parent_commit_ids.each do |parent_commit_id|
              git_diff = compute_git_diff_against(parent_commit_id)
              paths = compute_paths(git_diff)
              child_phrases = retrieve_child_phrases(paths)
              parent_phrases = retrieve_parent_phrases(parent_commit_ids, paths)
              phrase_diff = compare(child_phrases, parent_phrases)

              phrase_diff.each_pair do |state, phrases|
                final_diff[state].concat(phrases)
              end
            end
          end
        end

        def filter_phrase_diff(parent_commit_ids, phrase_diff)
          phrase_diff.each_with_object({}) do |(state, diff_entries), ret|
            ret[state] = diff_entries.select do |diff_entry|
              diff_entry.phrase.commit_id == commit_id ||
                diff_entry.state == :removed
            end
          end
        end

        def repo_config
          get_repo(repo_name)
        end

        def repo
          repo_config.repo
        end
      end

    end
  end
end
