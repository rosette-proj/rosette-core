# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates a locale by making sure the given repo has been configured
      # to support it.
      #
      # @example
      #   v = LocaleValidator.new
      #   v.valid?('ko-KR', 'my_repo', config)   # => true
      #   v.valid?('foo-BAR', 'my_repo', config) # => false
      #   v.messages  # => ["Repo 'my_repo' doesn't support the 'foo-BAR' locale"]
      class LocaleValidator < Validator
        # Returns true if the locale is valid, false otherwise.
        #
        # @param [String] locale_code The locale to validate.
        # @param [String] repo_name The repo to use. This method checks the
        #   entry in +configuration+ for +repo_name+ to see if it supports
        #   +locale_code+.
        # @param [Configurator] configuration The Rosette configuration to use.
        # @return [Boolean]
        def valid?(locale_code, repo_name, configuration)
          repo = configuration.get_repo(repo_name)
          if repo.get_locale(locale_code)
            true
          else
            messages << "Repo '#{repo_name}' doesn't support the '#{locale_code}' locale"
            false
          end
        end
      end

    end
  end
end
