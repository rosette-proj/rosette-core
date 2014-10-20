# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe SerializerId do
  module SerializersNoNaming
    module Foo
      class Bar; end
    end
  end

  module SerializersOneLevel
    module Foo
      class BarSerializer; end
    end
  end

  module SerializersTwoLevels
    module FooSerializer
      class BarSerializer; end
    end
  end

  let(:id) { SerializerId }

  describe '#resolve' do
    it 'resolves constants with no modified naming' do
      expect(id.resolve('foo/bar', SerializersNoNaming)).to(
        be(SerializersNoNaming::Foo::Bar)
      )
    end

    it 'resolves constants with one level of naming' do
      expect(id.resolve('foo/bar', SerializersOneLevel)).to(
        be(SerializersOneLevel::Foo::BarSerializer)
      )
    end

    it 'resolves constants with two levels of naming' do
      expect(id.resolve('foo/bar', SerializersTwoLevels)).to(
        be(SerializersTwoLevels::FooSerializer::BarSerializer)
      )
    end
  end
end
