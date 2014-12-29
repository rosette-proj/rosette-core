# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates an encoding.
      #
      # @example
      #   v = EncodingValidator.new
      #   v.valid?(Encoding::UTF_8, nil, nil) # => true
      #   v.valid?('foo', nil, nil)  # => false
      #   v.messages  # => ["Encoding 'foo' was not recognized."]
      class EncodingValidator < Validator
        # Returns true if the encoding is valid, false otherwise.
        #
        # @param [String, Encoding] encoding The encoding to validate.
        # @param [String] repo_name (not used)
        # @param [Configurator] configuration (not used)
        # @return [Boolean]
        def valid?(encoding, repo_name, configuration)
          Encoding.find(encoding)
          true
        rescue ArgumentError
          messages << "Encoding '#{encoding}' was not recognized."
          false
        end
      end

    end
  end
end
