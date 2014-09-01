# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class EncodingValidator < Validator
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
