# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe PreprocessorId do
  module PreprocessorsNoNaming
    module Foo
      class Bar; end
    end
  end

  module PreprocessorsOneLevel
    module Foo
      class BarPreprocessor; end
    end
  end

  module PreprocessorsTwoLevels
    module FooPreprocessor
      class BarPreprocessor; end
    end
  end

  let(:id) { PreprocessorId }

  describe '#resolve' do
    it 'resolves constants with no modified naming' do
      expect(id.resolve('foo/bar', PreprocessorsNoNaming)).to(
        be(PreprocessorsNoNaming::Foo::Bar)
      )
    end

    it 'resolves constants with one level of naming' do
      expect(id.resolve('foo/bar', PreprocessorsOneLevel)).to(
        be(PreprocessorsOneLevel::Foo::BarPreprocessor)
      )
    end

    it 'resolves constants with two levels of naming' do
      expect(id.resolve('foo/bar', PreprocessorsTwoLevels)).to(
        be(PreprocessorsTwoLevels::FooPreprocessor::BarPreprocessor)
      )
    end
  end
end
