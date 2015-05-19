# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Detects phrase changes between two git refs or commit ids. Identifies phrases
      # that have been added, removed, or changed. The refs used in the comparison
      # are referred to as a "head" and a "diff point". In Rosette/git parlance, a "head"
      # generally means a git ref that is currently being modified, i.e. a branch. A
      # "diff point" is some common ref to compare "head" to, often the repository's
      # "master" branch.
      #
      # Perhaps an easier way to visualize these concepts is through a git command-line
      # example. Imagine you're developing a feature to add widget support to your app.
      # You start work by switching to a new git branch (i.e. +git+ +checkout+ +-b+ +add_widgets+).
      # After adding a few files, changing some others, and deleting old code, you want
      # to see a complete set of all your changes. To do this, you run +git+ +diff+. At
      # this point, your "head" is your branch "add_widgets" and your "diff point" is
      # "master" (or whichever branch you were on when you ran +git+ +checkout+). You
      # could also have run +git+ +diff+ +master+ or +git+ +diff+ +master+ +HEAD+ to
      # get the same result. You can think of {DiffCommand} like a +git+ +diff+ command
      # of the form +git+ +diff+ +<diff+ +point>+ +<head>+.
      #
      # @see Rosette::Core::DiffFinder
      #
      # @example
      #   cmd = DiffCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_head_ref('my_branch')
      #     .set_diff_point_ref('master')
      #     .set_paths(['config/locales/en.yml'])
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
      #
      # @!attribute [r] head_commit_str
      #   @return [String] the raw head ref or commit id as set via {#set_head_ref}
      #     or {#set_head_commit_id}.
      #
      # @!attribute [r] diff_point_commit_str
      #   @return [String] the raw diff point ref or commit id as set via
      #     {#set_diff_point_ref} or {#set_diff_point_commit_id}.
      #
      # @!attribute [r] paths
      #   @return [Array] the list of paths to include in the diff. The diff will not
      #     contain phrases that were added/removed/modified in files that are not
      #     contained within this list.
      class DiffCommand < DiffBaseCommand
        attr_reader :head_commit_str, :diff_point_commit_str, :paths

        include WithRepoName

        validate :head_commit_str, type: :commit
        validate :diff_point_commit_str, type: :commit

        # Set the head commit id. Calling this method after {#set_head_ref} will
        # overwrite the head ref value. In other words, it's generally a good idea
        # to only call one of {#set_head_commit_id} or {#set_head_ref} but not both.
        #
        # @param [String] head_commit_id The head commit id.
        # @return [self]
        def set_head_commit_id(head_commit_id)
          @head_commit_str = head_commit_id
          self
        end

        # Set the head ref (i.e. a branch name). Calling this method after
        # {#set_head_commit_id} will overwrite the head commit id value. In other
        # words, it's generally a good idea to only call one of {#set_head_commit_id}
        # or {#set_head_ref} but not both.
        #
        # @param [String] head_ref The head ref.
        # @return [self]
        def set_head_ref(head_ref)
          @head_commit_str = head_ref
          self
        end

        # Set the diff point commit id. Calling this method after {#set_head_ref}
        # will overwrite the head ref value. In other words, it's generally a good
        # idea to only call one of {#set_head_commit_id} or {#set_head_ref} but
        # not both.
        #
        # @param [String] diff_point_commit_id The diff point commit id.
        # @return [self]
        def set_diff_point_commit_id(diff_point_commit_id)
          @diff_point_commit_str = diff_point_commit_id
          self
        end

        # Set the diff point ref (i.e. master). Calling this method after
        # {#set_diff_point_commit_id} will overwrite the diff point commit id value.
        # In other words, it's generally a good idea to only call one of
        # {#set_diff_point_commit_id} or {#set_diff_point_ref} but not both.
        #
        # @param [String] diff_point_ref The diff point ref.
        # @return [self]
        def set_diff_point_ref(diff_point_ref)
          @diff_point_commit_str = diff_point_ref
          self
        end

        # Set the list of paths to consider when computing the diff. Any paths not
        # in this list will not appear in the diff.
        #
        # @param [Array] paths The list of paths.
        # @return [self]
        def set_paths(paths)
          @paths = paths
          self
        end

        # Resolves the given head git ref or commit id and returns the corresponding
        # commit id. If {#set_head_ref} was used to set a git ref (i.e. branch name),
        # this method looks up and returns the corresponding commit id. If
        # {#set_head_commit_id} was used to set a commit id, then that commit id is
        # validated and returned.
        #
        # @return [String] The commit id set via either {#set_head_ref} or
        #   {#set_head_commit_id}.
        #
        # @raise [Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException]
        #   If either the commit id doesn't exist or the ref can't be found.
        def head_commit_id
          @head_commit_id ||= get_repo(repo_name)
            .repo.get_rev_commit(head_commit_str)
            .getId
            .name
        end

        # Resolves the given diff point git ref or commit id and returns the corresponding
        # commit id. If {#set_diff_point_ref} was used to set a git ref (i.e. branch name),
        # this method looks up and returns the corresponding commit id. If
        # {#set_diff_point_commit_id} was used to set a commit id, then that commit id is
        # validated and returned.
        #
        # @return [String] The commit id set via either {#set_diff_point_ref} or
        #   {#set_diff_point_commit_id}.
        #
        # @raise [Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException]
        #   If either the commit id doesn't exist or the ref can't be found.
        def diff_point_commit_id
          @diff_point_commit_id ||= get_repo(repo_name)
            .repo.get_rev_commit(diff_point_commit_str)
            .getId
            .name
        end

        # Computes the diff.
        # @return [Hash] a hash of differences, grouped by added/removed/modified keys. Each
        #   value is an array of phrases. For added and removed phrases, the phrase hashes
        #   will contain normal phrase attributes. For changed phrases, the phrase hashes
        #   will contain normal phrase attributes plus a special +old_key+ attribute that
        #   contains the previous key of the phrase. See the example above for a visual
        #   representation of the diff hash.
        def execute
          ensure_commits_have_been_processed([head_commit_id, diff_point_commit_id])
          repo_config = get_repo(repo_name)
          rev_walker = RevWalk.new(repo_config.repo.jgit_repo)
          diff_finder = DiffFinder.new(repo_config.repo.jgit_repo, rev_walker)

          repo = repo_config.repo
          diff = repo.diff(diff_point_commit_id, head_commit_id, [], diff_finder)
          head = repo.get_rev_commit(head_commit_id, rev_walker)

          head_snapshot = {}
          head_paths = []

          diff.each_pair do |_, diff_entries|
            diff_entries.each do |diff_entry|
              path = diff_entry.getNewPath
              if repo_config.extractor_configs.any? { |ext| ext.matches?(path) }
                head_snapshot[path] = head_commit_id
                head_paths << (path == '/dev/null' ? diff_entry.getOldPath : path)
              end
            end
          end

          head_phrases = datastore.phrases_by_commits(repo_name, head_snapshot).to_a
          diff_point_snapshot = take_snapshot(repo_config, diff_point_commit_id, head_paths)
          ensure_commits_have_been_processed(diff_point_snapshot.values)
          diff_point_phrases = datastore.phrases_by_commits(repo_name, diff_point_snapshot).to_a

          diff = compare(head_phrases, diff_point_phrases)
          commit_id_enum = repo_config.repo.each_commit_in_range(head_commit_id, diff_point_commit_id)
          commit_ids = commit_id_enum.map { |c| c.getId.name }

          diff.each_with_object({}) do |(state, diff_entries), ret|
            ret[state] = diff_entries.select do |diff_entry|
              commit_ids.include?(diff_entry.phrase.commit_id)
            end
          end
        end

        private

        def cache_key
          [
            'diffs', repo_name, head_commit_id,
            diff_point_commit_id, path_digest(Array(paths))
          ].join('/')
        end
      end

    end
  end
end
