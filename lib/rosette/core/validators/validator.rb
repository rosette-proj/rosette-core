# encoding: UTF-8

module Rosette
  module Core
    module Validators

      class Validator
        attr_reader :options

        def initialize(options = {})
          @options = options
        end

        def messages
          @messages ||= []
        end
      end

    end
  end
end
