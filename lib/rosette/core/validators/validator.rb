# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Base class for validators.
      #
      # @!attribute [r] options
      #   @return [Hash] a hash of options.
      class Validator
        attr_reader :options

        # Creates a new validator.
        #
        # @param [Hash] options A hash of options.
        def initialize(options = {})
          @options = options
        end

        # An array of error messages. Populated when +#valid?+ is called.
        #
        # @return [Array<String>] The list of error messages.
        def messages
          @messages ||= []
        end
      end

    end
  end
end
