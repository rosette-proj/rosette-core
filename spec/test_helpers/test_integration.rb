# encoding: UTF-8

module Rosette
  module Integrations

    module Test
      class TestIntegration < Rosette::Integrations::Integration
        def self.configure
          config = Configurator.new
          yield config if block_given?
          new(config)
        end

        def integrates_with?(obj)
          obj == :integratable
        end

        def integrate(obj)
        end

        class Configurator
          attr_reader :test_property

          def set_test_property(value)
            @test_property = value
          end
        end
      end
    end

  end
end
