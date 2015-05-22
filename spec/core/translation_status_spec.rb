# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe TranslationStatus do
  let(:phrase_count) { 10 }
  let(:german) { 'de-DE' }
  let(:korean) { 'ko-KR' }
  let(:status) { TranslationStatus.new(phrase_count) }

  describe '#add_locale_count' do
    it 'adds a locale and corresponding count' do
      status.add_locale_count(german, 5)
      expect(status.locale_counts[german]).to eq(5)
    end
  end

  describe '#locale_count' do
    it 'retrieves the translation count for the given locale' do
      status.add_locale_count(german, 5)
      expect(status.locale_count(german)).to eq(5)
    end
  end

  describe '#locales' do
    it 'returns a list of all added locales' do
      status.add_locale_count(german, 1)
      status.add_locale_count(korean, 2)
      expect(status.locales.sort).to eq([german, korean].sort)
    end
  end

  describe '#fully_translated_in?' do
    it 'returns true if the locale is fully translated' do
      status.add_locale_count(german, phrase_count)
      expect(status).to be_fully_translated_in(german)
    end

    it 'returns true if the locale contains more translations than phrases' do
      status.add_locale_count(german, phrase_count + 1)
      expect(status).to be_fully_translated_in(german)
    end

    it 'returns false if the locale is not fully translated' do
      status.add_locale_count(german, phrase_count - 1)
      expect(status).to_not be_fully_translated_in(german)
    end
  end

  describe '#fully_translated?' do
    it 'returns true if all locales are fully translated' do
      status.add_locale_count(german, phrase_count)
      status.add_locale_count(korean, phrase_count)
      expect(status).to be_fully_translated
    end

    it 'returns false if at least one locale is not fully translated' do
      status.add_locale_count(german, phrase_count)
      status.add_locale_count(korean, phrase_count - 1)
      expect(status).to_not be_fully_translated
    end
  end

  describe '#percent_translated' do
    it 'calculates the percent translated for the given locale' do
      status.add_locale_count(german, phrase_count / 2)
      expect(status.percent_translated(german)).to eq(0.5)
    end

    it 'returns 1.0 if translations outnumber phrases' do
      status.add_locale_count(german, phrase_count + 1)
      expect(status.percent_translated(german)).to eq(1.0)
    end

    context 'with an odd number of phrases' do
      let(:phrase_count) { 7 }

      it 'defaults to a precision of two decimal places' do
        status.add_locale_count(german, 3)
        expect(status.percent_translated(german)).to eq(0.43)
      end

      it 'rounds to the given number of decimal places' do
        status.add_locale_count(german, 3)
        expect(status.percent_translated(german, 3)).to eq(0.429)
      end
    end
  end
end
