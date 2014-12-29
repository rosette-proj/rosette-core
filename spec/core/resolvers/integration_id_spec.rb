# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe IntegrationId do
  module IntegrationsNoNaming
    module Foo
      class Bar; end
    end
  end

  module IntegrationsOneLevel
    module Foo
      class BarIntegration; end
    end
  end

  module IntegrationsTwoLevels
    module FooIntegration
      class BarIntegration; end
    end
  end

  let(:id) { IntegrationId }

  describe '#resolve' do
    it 'resolves constants with no modified naming' do
      expect(id.resolve('foo/bar', IntegrationsNoNaming)).to(
        be(IntegrationsNoNaming::Foo::Bar)
      )
    end

    it 'resolves constants with one level of naming' do
      expect(id.resolve('foo/bar', IntegrationsOneLevel)).to(
        be(IntegrationsOneLevel::Foo::BarIntegration)
      )
    end

    it 'resolves constants with two levels of naming' do
      expect(id.resolve('foo/bar', IntegrationsTwoLevels)).to(
        be(IntegrationsTwoLevels::FooIntegration::BarIntegration)
      )
    end
  end
end
