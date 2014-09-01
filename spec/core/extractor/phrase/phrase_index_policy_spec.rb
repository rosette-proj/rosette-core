# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe PhraseIndexPolicy do
  class PhraseIndexPolicyTester
    include PhraseIndexPolicy

    attr_reader :key, :meta_key

    def initialize
      @key, @meta_key = nil, nil
    end

    def set_key(key)
      @key = key
    end

    def set_meta_key(meta_key)
      @meta_key = meta_key
    end
  end

  let(:policy) { PhraseIndexPolicyTester }
  let(:policy_instance) { policy.new }

  describe '#index_key and #index_value' do
    it 'returns :meta_key if the key is nil' do
      policy_instance.set_meta_key('meta key')
      expect(policy_instance.index_key).to eq(:meta_key)
      expect(policy_instance.index_value).to eq('meta key')
    end

    it 'returns :key even if the key is emtpy (and the meta key is nil)' do
      policy_instance.set_key('')
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('')
    end

    it 'returns :key if the meta key is nil' do
      policy_instance.set_key('key')
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('key')
    end

    it 'returns :key if the meta key is empty' do
      policy_instance.set_meta_key('')
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('')
    end

    it 'returns :meta_key if both key and meta key are not nil (or empty)' do
      policy_instance.set_key('key')
      policy_instance.set_meta_key('meta key')
      expect(policy_instance.index_key).to eq(:meta_key)
      expect(policy_instance.index_value).to eq('meta key')
    end

    it 'returns :key if both key and meta key are empty' do
      policy_instance.set_key('')
      policy_instance.set_meta_key('')
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('')
    end

    it 'returns :key if both key and meta key are nil' do
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('')
    end

    it 'converts nils to empty strings' do
      expect(policy_instance.key).to be_nil
      expect(policy_instance.index_key).to eq(:key)
      expect(policy_instance.index_value).to eq('')
    end
  end

  describe 'self.index_key and self.index_value' do
    it 'returns :meta_key if the key is nil' do
      expect(policy.index_key(nil, 'meta key')).to eq(:meta_key)
      expect(policy.index_value(nil, 'meta key')).to eq('meta key')
    end

    it 'returns :key even if the key is emtpy (and the meta key is nil)' do
      expect(policy.index_key('', nil)).to eq(:key)
      expect(policy.index_value('', nil)).to eq('')
    end

    it 'returns :key if the meta key is nil' do
      expect(policy.index_key('key', nil)).to eq(:key)
      expect(policy.index_value('key', nil)).to eq('key')
    end

    it 'returns :key if the meta key is empty' do
      expect(policy.index_key(nil, '')).to eq(:key)
      expect(policy.index_value(nil, '')).to eq('')
    end

    it 'returns :meta_key if both key and meta key are not nil (or empty)' do
      expect(policy.index_key('key', 'meta key')).to eq(:meta_key)
      expect(policy.index_value('key', 'meta key')).to eq('meta key')
    end

    it 'returns :key if both key and meta key are empty' do
      expect(policy.index_key('', '')).to eq(:key)
      expect(policy.index_value('', '')).to eq('')
    end

    it 'returns :key if both key and meta key are nil (and converts nils to strings)' do
      expect(policy.index_key(nil, nil)).to eq(:key)
      expect(policy.index_value(nil, nil)).to eq('')
    end
  end
end
