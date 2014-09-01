# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class LocaleValidator < Validator
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
