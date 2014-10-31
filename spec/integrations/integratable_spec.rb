# encoding: UTF-8

require 'spec_helper'

include Rosette::Integrations

class IntegratableTestClass
  include Integratable
end

describe Integratable do
  let(:instance) { IntegratableTestClass.new }

  describe '#add_integration' do
    it 'resolves the integration id and adds the integration to the list' do
      instance.add_integration('test/test')
      instance.integrations.first.tap do |integration|
        expect(integration).to be_a(Test::TestIntegration)
      end
    end

    it 'yields a configurator' do
      instance.add_integration('test/test') do |integration_config|
        expect(integration_config).to be_a(Test::TestIntegration::Configurator)
        integration_config.set_test_property('foobar')
      end

      instance.integrations.first.tap do |integration|
        expect(integration.configuration.test_property).to eq('foobar')
      end
    end
  end

  describe '#get_integration' do
    it 'returns the integration instance by id' do
      instance.add_integration('test/test')
      instance.get_integration('test/test').tap do |integration|
        expect(integration).to be_a(Test::TestIntegration)
      end
    end

    it "returns nil if the integration hasn't been configured" do
      expect(instance.get_integration('test/test')).to be_nil
    end

    it "returns nil if the integration doesn't exist" do
      expect(instance.get_integration('foo/bar')).to be_nil
    end
  end

  describe '#apply_integrations' do
    it 'iterates over the list of integrations and applies them to the given object' do
      instance.add_integration('test/test')
      expect(instance.integrations.first).to receive(:integrate).with(:integratable)
      instance.apply_integrations(:integratable)
    end
  end
end
