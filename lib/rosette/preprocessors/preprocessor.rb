# encoding: UTF-8

module Rosette
  module Preprocessors

    # Base class for all of Rosette's pre-processors.
    #
    # @!attribute [r] configuration
    #   @return [Object] an instance of this pre-processor's configurator.
    class Preprocessor
      attr_reader :configuration

      # Creates a new pre-processor.
      #
      # @param [Object] configuration An instance of this pre-processor's
      #   configurator.
      def initialize(configuration)
        @configuration = configuration
      end

      # Processes the given object.
      #
      # @param [Object] object The object to process.
      # @return [Object] A copy of +object+, modified as per this
      #   pre-processor's functionality. If the object can be processed
      #   but doesn't need to be, the original object is returned without
      #   modifications.
      # @raise [UnsupportedObjectError] Raised if the object is not
      #   processable.
      def process(object)
        should_process = !configuration.applies_to_proc ||
          configuration.applies_to_proc.call(object)

        if should_process
          if method = method_for(object)
            send(method, object)
          else
            raise Rosette::Preprocessors::Errors::UnsupportedObjectError,
              "don't know how to preprocess a(n) #{object.class.name}"
          end
        else
          object
        end
      end
    end

  end
end
