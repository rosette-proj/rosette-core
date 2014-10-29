# encoding: UTF-8

module Rosette
  module Integrations
    class Integration

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

    end
  end
end
