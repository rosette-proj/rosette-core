# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # The base class for commands that need to calculate diffs.
      class DiffBaseCommand < GitCommand
        attr_reader :strict
        alias_method :strict?, :strict

        def initialize(*args)
          super
          @strict = true
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

        include WithSnapshots

        def diff_between(commit_id, parent_commit_ids, paths = nil)
          # handle the case where this is the first commit (or there are no
          # processed parents)
          if parent_commit_ids.empty?
            entries = retrieve_child_phrases(commit_id, []).map do |p|
              DiffEntry.new(p, :added)
            end

            { added: entries, removed: [], modified: [] }
          else
            calculate_phrase_diff_against(commit_id, parent_commit_ids, paths)
          end
        end

        def ensure_commits_have_been_processed(commits)
          commits.uniq.each do |commit_id|
            if commit_id
              unless commit_exists?(repo_name, commit_id)
                raise Errors::UnprocessedCommitError,
                  "Commit #{commit_id} has not been processed yet."
              end
            end
          end
        end

        def commit_exists?(repo_name, commit_id)
          datastore.commit_log_exists?(repo_name, commit_id)
        end

        def compare(head_phrases, diff_point_phrases)
          partitioned_head_phrases = partition_phrases(head_phrases)
          partitioned_diff_point_phrases = partition_phrases(diff_point_phrases)
          join_diffs(
            key_diff(partitioned_head_phrases, partitioned_diff_point_phrases),
            meta_key_diff(partitioned_head_phrases, partitioned_diff_point_phrases)
          )
        end

        def join_diffs(diff1, diff2)
          # we don't care about :unmodified, so leave it out
          [:added, :removed, :modified].each_with_object({}) do |state, ret|
            ret[state] = diff1[state] + diff2[state]
          end
        end

        def key_diff(partitioned_head_phrases, partitioned_diff_point_phrases)
          diff = Hash.new { |hash, key| hash[key] = [] }

          key_head_to_diff_point(
            partitioned_head_phrases.first,
            partitioned_diff_point_phrases.first
          ) do |phrase, state, old_phrase|
            diff[state] << DiffEntry.new(phrase, state, old_phrase)
          end

          key_diff_point_to_head(
            partitioned_head_phrases.first,
            partitioned_diff_point_phrases.first
          ) do |phrase, state, old_phrase|
            diff[state] << DiffEntry.new(phrase, state, old_phrase)
          end

          diff
        end

        def key_head_to_diff_point(head_phrases, diff_point_phrases)
          if block_given?
            head_phrases.each do |head_phrase|
              phrase = diff_point_phrases.find do |diff_point_phrase|
                diff_point_phrase.key == head_phrase.key &&
                  diff_point_phrase.file == head_phrase.file
              end

              state = phrase ? :unmodified : :added
              yield head_phrase, state
            end
          else
            to_enum(__method__, head_phrases, diff_point_phrases)
          end
        end

        def key_diff_point_to_head(head_phrases, diff_point_phrases)
          if block_given?
            diff_point_phrases.each do |diff_point_phrase|
              phrase = head_phrases.find do |head_phrase|
                head_phrase.key == diff_point_phrase.key &&
                  head_phrase.file == diff_point_phrase.file
              end

              unless phrase
                yield diff_point_phrase, :removed
              end
            end
          else
            to_enum(__method__, head_phrases, diff_point_phrases)
          end
        end

        def meta_key_diff(partitioned_head_phrases, partitioned_diff_point_phrases)
          diff = Hash.new { |hash, key| hash[key] = [] }

          meta_key_head_to_diff_point(
            partitioned_head_phrases.last,
            partitioned_diff_point_phrases.last
          ) do |phrase, state, old_phrase|
            diff[state] << DiffEntry.new(phrase, state, old_phrase)
          end

          meta_key_diff_point_to_head(
            partitioned_head_phrases.last,
            partitioned_diff_point_phrases.last
          ) do |phrase, state, old_phrase|
            diff[state] << DiffEntry.new(phrase, state, old_phrase)
          end

          diff
        end

        # identifies phrases in head that:
        #   are not in diff point ('added')
        #   have the same meta key but different keys as a phrase in diff point ('modified')
        #   are identical to a phrase in diff point ('unmodified')
        def meta_key_head_to_diff_point(head_phrases, diff_point_phrases)
          if block_given?
            # iterate over all head phrases that have meta keys
            head_phrases.each do |head_phrase|
              idx = diff_point_phrases.find_index do |diff_point_phrase|
                diff_point_phrase.meta_key == head_phrase.meta_key &&
                  diff_point_phrase.file == head_phrase.file
              end

              state = if idx
                if diff_point_phrases[idx].key == head_phrase.key
                  :unmodified
                else
                  :modified
                end
              else
                :added
              end

              if state == :modified
                yield head_phrase, state, diff_point_phrases[idx]
              else
                yield head_phrase, state
              end
            end
          else
            to_enum(__method__, head_phrases, diff_point_phrases)
          end
        end

        # identifies phrases in diff point that are not in head ('removed')
        def meta_key_diff_point_to_head(head_phrases, diff_point_phrases)
          if block_given?
            diff_point_phrases.each do |diff_point_phrase|
              idx = head_phrases.find_index do |head_phrase|
                head_phrase.meta_key == diff_point_phrase.meta_key &&
                  head_phrase.file == diff_point_phrase.file
              end

              unless idx
                yield diff_point_phrase, :removed
              end
            end
          else
            to_enum(__method__, head_phrases, diff_point_phrases)
          end
        end

        def partition_phrases(phrases)
          phrases.partition { |ph| ph.index_key == :key }
        end

        # if parent_commit_id is processed, it will get returned (i.e. it will
        # start looking at parent_commit_id, not parent_commit_id - 1).
        def get_closest_processed_parent(parent_commit_id)
          parent = repo.each_commit_starting_at(parent_commit_id).find do |rev|
            commit_exists?(repo_name, rev.getId.name)
          end

          parent.getId.name if parent
        end

        def calculate_phrase_diff_against(commit_id, parent_commit_ids, paths)
          { added: [], modified: [], removed: [] }.tap do |final_diff|
            parent_commit_ids.each do |parent_commit_id|
              git_diff = compute_git_diff_between(commit_id, parent_commit_id)
              paths ||= compute_paths(git_diff)
              child_phrases = retrieve_child_phrases(commit_id, paths)
              parent_phrases = retrieve_parent_phrases(parent_commit_id, paths)
              phrase_diff = compare(child_phrases, parent_phrases)

              phrase_diff.each_pair do |state, phrases|
                final_diff[state].concat(phrases)
              end
            end
          end
        end

        def compute_git_diff_between(commit_id, parent_commit_id)
          rev_walker = RevWalk.new(repo.jgit_repo)
          diff_finder = DiffFinder.new(repo.jgit_repo, rev_walker)
          repo.diff([parent_commit_id], commit_id, [], diff_finder)
        end

        def compute_paths(diff)
          child_paths = []

          diff.each_with_object([]) do |(_, diff_entries), ret|
            diff_entries.each do |diff_entry|
              path = get_path(diff_entry)

              if repo_config.extractor_configs.any? { |ext| ext.matches?(path) }
                ret << path
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

        def retrieve_child_phrases(commit_id, paths)
          snapshot = take_snapshot(repo_config, commit_id, paths)
          datastore.phrases_by_commits(repo_name, snapshot).to_a
        end

        def retrieve_parent_phrases(parent_commit_id, paths)
          ensure_commits_have_been_processed([parent_commit_id])

          parent_snapshot = take_snapshot(
            repo_config, parent_commit_id, paths
          )

          datastore.phrases_by_commits(repo_name, parent_snapshot).to_a
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
