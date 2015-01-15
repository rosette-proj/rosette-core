# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe StatusCommand do
  let(:repo_name) { 'single_commit' }
  let(:locales) { %w(es de-DE ja-JP) }
  let(:phrase_model) { Rosette::DataStores::InMemoryDataStore::Phrase }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_locales(locales)
    end
  end

  let(:command) { AddOrUpdateTranslationCommand.new(fixture.config) }

  context 'validations' do
    it 'requires a valid repo name' do
      command.set_refs(['HEAD'])
      command.set_locale(locales.first)
      expect(command).to_not be_valid
    end

    it 'requires a ref' do
      command.set_repo_name(repo_name)
      command.set_locale(locales.first)
      expect(command).to_not be_valid
    end

    it 'requires a locale' do
      command.set_repo_name(repo_name)
      command.set_refs(['HEAD'])
      expect(command).to_not be_valid
    end

    it 'should be valid if the repo name, locale, and ref are set' do
      command.set_repo_name(repo_name)
      command.set_locale(locales.first)
      command.set_refs(['HEAD'])
      expect(command).to be_valid
    end
  end

  context '#execute' do
    let(:meta_key) { 'cool.meta_key' }
    let(:key) { 'cool key' }
    let(:translation) { 'Llave padre' }

    before do
      command.set_repo_name(repo_name)
        .set_locale(locales.first)
        .set_refs(['HEAD'])
        .set_key(key)
        .set_meta_key(meta_key)
        .set_translation(translation)

      @phrase = phrase_model.create({
        commit_id: head_ref(fixture.repo),
        key: key,
        meta_key: meta_key,
        file: 'first_file.txt',
        repo_name: repo_name
      })
    end

    it 'adds a translation to the datastore' do
      expect(@phrase.translations.size).to eq(0)
      command.execute
      expect(@phrase.translations.size).to eq(1)

      @phrase.translations.first.tap do |trans|
        expect(trans.translation).to eq(translation)
        expect(trans.phrase.key).to eq(key)
        expect(trans.phrase.meta_key).to eq(meta_key)
      end
    end
  end

  def head_ref(repo)
    repo.git('rev-parse HEAD').strip
  end
end
