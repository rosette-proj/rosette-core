# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe StringUtils do
  let(:utils) { Rosette::Core::StringUtils }

  describe '#camelize' do
    it 'treats underscores as capitalization boundaries' do
      expect(utils.camelize('foo_bar')).to eq('FooBar')
    end

    it 'treats dashes as capitalization boundaries' do
      expect(utils.camelize('foo-bar')).to eq('FooBar')
    end
  end
end
