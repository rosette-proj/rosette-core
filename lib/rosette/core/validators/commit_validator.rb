# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class CommitValidator < Validator
        def valid?(commit_str, repo_name, configuration)
          if repo_config = configuration.get_repo(repo_name)
            repo_config.repo.get_rev_commit(commit_str)
            true
          else
            messages << "Unable to find repo #{repo_name}."
            false
          end
        rescue Java::JavaLang::IllegalArgumentException
          messages << "Unable to find commit '#{commit_str}'."
          false
        end
      end

    end
  end
end
