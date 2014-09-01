# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe PhraseToHash do
  describe '#to_h' do
    it 'returns a hash of the appropriate attributes' do
      TestPhrase.new('key', 'meta key', 'file', 'commit id') do |t|
        expect(t.to_h).to eq({
          key: 'key', meta_key: 'meta key',
          file: 'file', commit_id: 'commit id'
        })
      end
    end
  end
end
