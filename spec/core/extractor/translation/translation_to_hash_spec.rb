# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe TranslationToHash do
  describe '#to_h' do
    let(:phrase) do
      TestPhrase.new('key', 'meta key', 'file', 'commit id')
    end

    it 'returns a hash of the appropriate attributes' do
      TestTranslation.new(translation: 'translation', locale: 'es', phrase: phrase) do |t|
        expect(t.to_h).to eq({
          translation: 'translation', locale: 'es',
          phrase: {
            key: 'key', meta_key: 'meta key',
            file: 'file', commit_id: 'commit id'
          }
        })
      end
    end
  end
end
