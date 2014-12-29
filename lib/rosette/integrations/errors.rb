# encoding: UTF-8

module Rosette
  module Integrations

    # Errors that can be raised during integration operations.
    module Errors
      # Raised whenever an integration is deemed impossible. Impossible
      # integrations happen when Rosette can't determine how an integration
      # should be applied to the system.
      class ImpossibleIntegrationError < StandardError; end
    end

  end
end
