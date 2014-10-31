# encoding: UTF-8

module Rosette
  module Integrations

    module Integratable
      def integrations
        @integrations ||= []
      end

      def add_integration(integration_id, &block)
        klass = Rosette::Core::IntegrationId.resolve(integration_id)
        integrations << klass.configure(&block)
      end

      def get_integration(integration_id)
        klass = Rosette::Core::IntegrationId.resolve(integration_id)

        if klass
          integrations.find do |integration|
            integration.is_a?(klass)
          end
        end
      rescue ArgumentError
      end

      def apply_integrations(obj)
        integrations.each do |integration|
          if integration.integrates_with?(obj)
            integration.integrate(obj)
          end
        end
      end
    end

  end
end
