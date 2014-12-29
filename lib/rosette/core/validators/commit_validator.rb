# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates the existence of a commit.
      #
      # @example
      #   v = CommitValidator.new
      #   v.valid?('73cd130a42017d794ffa86ef0d255541d518a7b3', 'my_repo', config)
      #   # => true
      #
      #   v.valid?('non-existent-ref', 'my_repo', config)
      #   # => false
      #
      #   v.messages  # => ["Unable to find commit 'non-existent-ref'."]
      class CommitValidator < Validator
        # Returns true if the commit is valid, false otherwise. Also returns false if
        # +repo_name+ isn't a valid repo configured in +configuration+.
        #
        # @param [String] commit_str The commit to validate.
        # @param [String] repo_name The repo to look for +commit_str+ in.
        # @param [Configurator] configuration The Rosette configuration to use.
        # @return [Boolean]
        def valid?(commit_str, repo_name, configuration)
          if repo_config = configuration.get_repo(repo_name)
            commit = repo_config.repo.get_rev_commit(commit_str)
            validate_commit(commit)
          else
            messages << "Unable to find repo #{repo_name}."
            false
          end
        rescue Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException
          messages << "Unable to find commit '#{commit_str}'."
          false
        end

        private

        def validate_commit(commit)
          if options.fetch(:allow_merge_commit, true)
            true
          else
            if commit.getParentCount > 1
              messages << "Unable to validate #{commit.getId.name} because it's a merge commit."
              false
            else
              true
            end
          end
        end
      end

    end
  end
end
