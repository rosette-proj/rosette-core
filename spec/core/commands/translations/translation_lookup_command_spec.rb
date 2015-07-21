# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands
include Rosette::DataStores
include Rosette::Core

describe TranslationLookupCommand do
  let(:repo_name) { 'single_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
      repo_config.add_locale('de-DE')
    end
  end

  let(:locale) { repo_config.locales.first }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }
  let(:repo_config) { fixture.config.get_repo(repo_name) }
  let(:rosette_config) { fixture.config }
  let(:command) do
    TranslationLookupCommand.new(rosette_config)
      .set_repo_name(repo_name)
      .set_locale('de-DE')
      .set_commit_id(commit_id)
  end

  describe '#execute' do
    let!(:phrase1) do
      InMemoryDataStore::Phrase.create(
        key: 'sweet phrase', meta_key: 'sweet.phrase',
        repo_name: repo_name, commit_id: commit_id
      )
    end

    let!(:phrase2) do
      InMemoryDataStore::Phrase.create(
        key: 'perfect phrase', meta_key: 'perfect.phrase',
        repo_name: repo_name, commit_id: commit_id
      )
    end

    it 'looks up the translation string' do
      repo_config.tms.store_phrases([phrase1, phrase2], commit_id)
      repo_config.tms.auto_translate(locale, phrase1)
      repo_config.tms.auto_translate(locale, phrase2)

      command.set_meta_key(phrase1.meta_key)
      expect(command.execute).to eq('eetsway asephray')

      command.set_meta_key(phrase2.meta_key)
      expect(command.execute).to eq('erfectpay asephray')
    end
  end
end
