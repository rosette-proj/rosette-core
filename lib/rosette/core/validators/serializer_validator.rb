# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class SerializerValidator < Validator
        def valid?(serializer_id, repo_name, configuration)
          repo = configuration.get_repo(repo_name)
          if repo.get_serializer_config(serializer_id)
            true
          else
            messages << "Unable to find serializer #{serializer_id}"
            false
          end
        end
      end

    end
  end
end
