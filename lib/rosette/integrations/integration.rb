# encoding: UTF-8

module Rosette
  module Integrations

    # The base class for all integrations.
    #
    # @!attribute [r] configuration
    #   @return [Configurator] the Rosette config.
    class Integration
      attr_reader :configuration

      # Creates a new integration instance.
      #
      # @param [Object] configuration an instance of this integration's
      #   configurator.
      def initialize(configuration)
        @configuration = configuration
      end
    end

  end
end
