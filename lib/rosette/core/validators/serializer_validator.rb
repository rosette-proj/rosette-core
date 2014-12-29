# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates a serializer by making sure the given repo has been configured
      # to support it.
      #
      # @example
      #   v = SerializerValidator.new
      #   v.valid?('yaml/rails', 'my_repo', config)  # => true
      #   v.valid?('yaml/blarg', 'my_repo', config)  # => false
      #   v.messages  # => ["Unable to find serializer 'yaml/blarg'."]
      class SerializerValidator < Validator
        # Returns true if the serializer is valid, false otherwise.
        #
        # @param [String] serializer_id The serializer to validate.
        # @param [String] repo_name The repo to use. This method checks the
        #   entry in +configuration+ for +repo_name+ to see if it supports
        #   +serializer_id+.
        # @param [Configurator] configuration The Rosette configuration to use.
        # @return [Boolean]
        def valid?(serializer_id, repo_name, configuration)
          repo = configuration.get_repo(repo_name)
          if repo.get_serializer_config(serializer_id)
            true
          else
            messages << "Unable to find serializer '#{serializer_id}'."
            false
          end
        end
      end

    end
  end
end
