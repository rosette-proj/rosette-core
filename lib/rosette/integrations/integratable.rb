# encoding: UTF-8

module Rosette
  module Integrations

    # Intended to be mixed in to classes that can be integrated with. Provides
    # methods to add and retrieve integration configs as well as apply
    # configured integrations to the parent.
    module Integratable
      # Returns the current list of integration configs.
      #
      # @return [Array]
      def integrations
        @integrations ||= []
      end

      # Add an integration. Yields an instance of the integration's
      # configurator object to the given block.
      #
      # @param [String] integration_id The id of the integration to add.
      # @yield [config]
      # @yieldparam config The integration's configurator.
      # @return [void]
      def add_integration(integration_id, &block)
        klass = Rosette::Core::IntegrationId.resolve(integration_id)
        integrations << klass.configure(&block)
      end

      # Retrieve the integration config by id.
      #
      # @param [String] integration_id The integration id.
      # @return [nil, Object] The integration's configurator.
      def get_integration(integration_id)
        klass = Rosette::Core::IntegrationId.resolve(integration_id)

        if klass
          integrations.find do |integration|
            integration.is_a?(klass)
          end
        end
      rescue ArgumentError
      end

      # Applies the integrations to the given object.
      #
      # @param [Object] obj The object to apply the integrations to.
      # @return [void]
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
