# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class CommitValidator < Validator
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
