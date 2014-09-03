# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe Extractor do
  let(:extractor) do
    Rosette::Extractors::Test::TestExtractor.new
  end

  describe '#extract_each_from' do
    it 'extracts each line from the text file and yields the results' do
      extractor.extract_each_from("foo\nbar").tap do |extract_enum|
        expect(extract_enum).to be_a(Enumerator)
        extract_enum.to_a.tap do |phrases|
          expect(phrases.size).to eq(2)
          expect(phrases.all? { |phrase| phrase.is_a?(Phrase) }).to be_truthy
          expect(phrases.first.key).to eq('foo')
          expect(phrases.last.key).to eq('bar')
        end
      end
    end
  end
end
