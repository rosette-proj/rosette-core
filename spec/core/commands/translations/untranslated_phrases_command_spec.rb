# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands
include Rosette::DataStores
# include Rosette::Core

describe UntranslatedPhrasesCommand do
  let(:repo_name) { 'single_commit' }
  let(:locale) { repo_config.locales.first }
  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
      repo_config.add_locale('de-DE')
    end
  end

  let(:command) do
    UntranslatedPhrasesCommand.new(rosette_config)
      .set_repo_name(repo_name)
      .set_commit_id(commit_id)
  end

  describe '#execute' do
    before(:each) do
      fixture.repo.each_commit_id do |commit_id|
        CommitCommand.new(rosette_config)
          .set_repo_name(repo_name)
          .set_commit_id(commit_id)
          .execute
      end
    end

    it 'identifies the missing translation' do
      InMemoryDataStore::Phrase.entries.each_with_index do |phrase, idx|
        next if idx == 0  # skip one translation
        repo_config.tms.auto_translate(locale, phrase)
      end

      untrans = InMemoryDataStore::Phrase.entries.first

      result = command.execute
      expect(result).to include('de-DE')
      expect(result['de-DE'].size).to eq(1)
      expect(result['de-DE'].first.key).to eq(untrans.key)
      expect(result['de-DE'].first.meta_key).to eq(untrans.meta_key)
    end
  end
end
