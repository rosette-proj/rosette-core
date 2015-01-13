# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe CommitCommand do
  let(:klass) { CommitCommand }
  let(:repo_name) { 'single_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:command) { CommitCommand.new(fixture.config) }
  let(:phrase_model) { Rosette::DataStores::InMemoryDataStore::Phrase }

  context 'validation' do
    it 'requires a valid repo name' do
      command.set_ref('HEAD')
      expect(command).to_not be_valid
    end

    it 'requires a valid ref' do
      command.set_repo_name('foo')
      expect(command).to_not be_valid
    end

    it 'should be valid if both the repo name and ref are set' do
      command.set_ref('HEAD')
      command.set_repo_name(repo_name)
      expect(command).to be_valid
    end
  end

  context 'with valid options' do
    before(:each) do
      command.set_ref('HEAD')
      command.set_repo_name(repo_name)
    end

    describe '#execute' do
      it 'extracts and stores all phrases' do
        command.execute
        expect(phrase_model.entries.map(&:key).sort).to eq([
          "I'm a little teapot",
          'The green albatross flitters in the moonlight',
          'Chatanooga Choo Choo',
          "Diamonds are a girl's best friend.",
          'Cash for the merchandise; cash for the fancy goods.',
          "I'm in Spañish.",
          ' test string 1',
          ' test string 2'
        ].sort)
      end
    end
  end
end
