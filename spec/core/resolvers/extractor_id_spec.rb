# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe ExtractorId do
  module ExtractorsNoNaming
    module Foo
      class Bar; end
    end
  end

  module ExtractorsOneLevel
    module Foo
      class BarExtractor; end
    end
  end

  module ExtractorsTwoLevels
    module FooExtractor
      class BarExtractor; end
    end
  end

  let(:id) { ExtractorId }

  describe '#resolve' do
    it 'resolves constants with no modified naming' do
      expect(id.resolve('foo/bar', ExtractorsNoNaming)).to(
        be(ExtractorsNoNaming::Foo::Bar)
      )
    end

    it 'resolves constants with one level of naming' do
      expect(id.resolve('foo/bar', ExtractorsOneLevel)).to(
        be(ExtractorsOneLevel::Foo::BarExtractor)
      )
    end

    it 'resolves constants with two levels of naming' do
      expect(id.resolve('foo/bar', ExtractorsTwoLevels)).to(
        be(ExtractorsTwoLevels::FooExtractor::BarExtractor)
      )
    end
  end
end
