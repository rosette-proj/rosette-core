# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class RepoValidator < Validator
        def valid?(repo_name, _, configuration)
          if !configuration.get_repo(repo_name)
            messages << "Unable to find repo #{repo_name}."
            false
          else
            true
          end
        end
      end

    end
  end
end
