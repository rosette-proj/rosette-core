# encoding: UTF-8

module Rosette
  module Preprocessors

    class Preprocessor
      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def process(object)
        should_process = !configuration.applies_to_proc ||
          configuration.applies_to_proc.call(object)

        if should_process
          if method = method_for(object)
            send(method, object)
          else
            raise Rosette::Preprocessors::Errors::UnsupportedObjectError,
              "don't know how to preprocess a #{object.class.name}"
          end
        else
          object
        end
      end
    end

  end
end
