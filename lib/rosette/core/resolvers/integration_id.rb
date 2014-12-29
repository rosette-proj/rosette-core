# encoding: UTF-8

module Rosette
  module Core

    # Logic for handling integration ids. Integration ids are strings that refer
    # to a particular integration class. For example, the id 'smartling' refers
    # to +Rosette::Integrations::SmartlingIntegration+.
    #
    # @example
    #   IntegrationId.resolve('smartling')
    #   # => Rosette::Integrations::SmartlingIntegration
    class IntegrationId < Resolver
      class << self

        # Parses and identifies the class constant for the given integration id.
        #
        # @param [Class, String] id When given a class, returns the class. When
        #   given a string, parses and identifies the corresponding class
        #   constant in +namespace+.
        # @param [Class] namespace The namespace to look in.
        # @return [Class] The identified class constant.
        def resolve(integration_id, namespace = Rosette::Integrations)
          super
        end

        private

        def suffix
          'Integration'
        end

      end
    end

  end
end
