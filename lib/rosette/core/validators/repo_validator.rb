# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates a repo by making sure it has been configured.
      #
      # @example
      #   v = RepoValidator.new
      #   v.valid?('my_repo', nil, config)   # => true
      #   v.valid?('bad_repo', nil, config)  # => false
      #   v.messages  # => ["Unable to find repo 'bad_repo'."]
      class RepoValidator < Validator
        # Returns true if the repo is valid, false otherwise
        #
        # @param [String] repo_name The repo to validate.
        # @param [String] _ (not used)
        # @param [Configurator] configuration The Rosette configuration to use.
        # @return [Boolean]
        def valid?(repo_name, _, configuration)
          if !configuration.get_repo(repo_name)
            messages << "Unable to find repo '#{repo_name}'."
            false
          else
            true
          end
        end
      end

    end
  end
end
