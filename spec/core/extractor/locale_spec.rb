# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe Locale do
  let(:locale) { Locale }

  describe 'self.parse' do
    it 'returns a locale object' do
      expect(locale.parse('es_MX')).to be_a(Locale)
    end

    it "raises an error if the locale format isn't recognized" do
      expect(lambda { locale.parse('es_MX', :foo) }).to(
        raise_error(ArgumentError)
      )
    end
  end
end

describe Bcp47Locale do
  let(:locale) { Bcp47Locale }

  describe 'self.parse' do
    it 'returns a locale object with the correct language and territory' do
      locale.parse('es_MX').tap do |locale|
        expect(locale).to be_a(Bcp47Locale)
        expect(locale.language).to eq('es')
        expect(locale.territory).to eq('MX')
      end
    end

    it 'returns a locale object with a blank territory when not specified' do
      locale.parse('es').tap do |locale|
        expect(locale).to be_a(Bcp47Locale)
        expect(locale.language).to eq('es')
        expect(locale.territory).to be_nil
      end
    end

    it 'raises an error if the locale is invalid' do
      expect(lambda { locale.parse('es_MXFGOA') }).to(
        raise_error(InvalidLocaleError)
      )
    end
  end

  describe 'self.valid?' do
    it 'ensures locale contains a 2 to 4 char language code' do
      expect(locale.valid?('es')).to be_truthy
      expect(locale.valid?('foobar')).to be_falsy
    end

    it 'validates the optional 2 to 5 character territory code' do
      expect(locale.valid?('es_MX')).to be_truthy
      expect(locale.valid?('es_MXFGOA')).to be_falsy
    end

    it 'allows both dashes and underscores to be used' do
      expect(locale.valid?('es_MX')).to be_truthy
      expect(locale.valid?('es-MX')).to be_truthy
    end
  end

  describe '#code' do
    it 'includes the language and territory' do
      loc = locale.new('es', 'MX')
      expect(loc.code).to eq('es-MX')
    end

    it "doesn't include the territory if nil" do
      loc = locale.new('es')
      expect(loc.code).to eq('es')
    end
  end

  describe '#eql?' do
    it 'equates two locales with the same language and territory' do
      expect(locale.new('es', 'MX')).to eq(locale.new('es', 'mx'))
    end

    it 'does not equate two locales with different territories' do
      expect(locale.new('es', 'MX')).to_not eq(locale.new('es', 'PE'))
    end

    it 'does not equate two locales with different languages' do
      expect(locale.new('fr', 'CA')).to_not eq(locale.new('en', 'CA'))
    end
  end
end
