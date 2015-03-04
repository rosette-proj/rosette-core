# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe TranslationsPathConfig do
  it 'instantiates the extractor given' do
    TranslationsPathConfig.new.tap do |config|
      expect(config.root).to be_instance_of(PathMatcherFactory::Node)
    end
  end

  it 'delegates #matches? to root' do
    config = TranslationsPathConfig.new.tap do |config|
      config.set_conditions do |cond|
        cond.match_regex(/values-(ja|de)/)
      end
    end

    expect(config.matches?('MyProject/stuff/values-ja')).to be_truthy
    expect(config.matches?('MyProject/stuff/values-pt')).to be_falsey
  end
end
