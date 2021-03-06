# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe ExtractorConfig do
  let(:extractor_class) { Rosette::Extractors::Test::TestExtractor }

  it 'instantiates the extractor given' do
    ExtractorConfig.new(extractor_class).tap do |config|
      expect(config.extractor).to be_instance_of(extractor_class)
    end
  end

  it 'sets a default encoding' do
    ExtractorConfig.new(extractor_class).tap do |config|
      expect(config.encoding).to eq(Rosette::Core::DEFAULT_ENCODING)
    end
  end

  describe '#set_encoding' do
    let(:config) { ExtractorConfig.new(extractor_class) }

    it 'sets the encoding on the instance' do
      config.set_encoding(Encoding::UTF_16BE).tap do |config_with_encoding|
        expect(config_with_encoding).to be(config)
        expect(config_with_encoding.encoding).to eq(Encoding::UTF_16BE)
      end
    end
  end

  describe '#matches?' do
    let(:config) { ExtractorConfig.new(extractor_class) }

    it 'delegates #matches? to root' do
      config.set_conditions do |cond|
        cond.match_regex(/values-(ja|de)/)
      end

      expect(config.matches?('MyProject/stuff/values-ja')).to be_truthy
      expect(config.matches?('MyProject/stuff/values-pt')).to be_falsey
    end
  end
end
