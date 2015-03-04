# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe ExtractorConfig do
  let(:extractor_class) { Rosette::Extractors::Test::TestExtractor }
  let(:extractor_id) { 'test/test' }

  it 'instantiates the extractor given' do
    ExtractorConfig.new(extractor_id, extractor_class).tap do |config|
      expect(config.extractor).to be_instance_of(extractor_class)
      expect(config.extractor_id).to eq(extractor_id)
    end
  end

  it 'sets a default encoding' do
    ExtractorConfig.new(extractor_id, extractor_class).tap do |config|
      expect(config.encoding).to eq(Rosette::Core::DEFAULT_ENCODING)
    end
  end

  describe '#set_encoding' do
    let(:config) { ExtractorConfig.new(extractor_id, extractor_class) }

    it 'sets the encoding on the instance' do
      config.set_encoding(Encoding::UTF_16BE).tap do |config_with_encoding|
        expect(config_with_encoding).to be(config)
        expect(config_with_encoding.encoding).to eq(Encoding::UTF_16BE)
      end
    end
  end
end
