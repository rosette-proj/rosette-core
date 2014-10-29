# encoding: UTF-8

module Rosette
  module Core

    class IntegrationId < Resolver
      class << self

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
