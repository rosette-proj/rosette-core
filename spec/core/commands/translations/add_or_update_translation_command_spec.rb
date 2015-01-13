# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe StatusCommand do
  let(:repo_name) { 'single_commit' }
  let(:locales) { %w(es de-DE ja-JP) }
  let(:translation_model) { Rosette::DataStores::InMemoryDataStore::Translation }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_locales(locales)
    end
  end

  let(:command) { AddOrUpdateTranslationCommand.new(fixture.config) }

  context 'validations' do
    it 'requires a valid repo name' do
      command.set_ref('HEAD')
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
      command.set_ref('HEAD')
      expect(command).to_not be_valid
    end

    it 'should be valid if the repo name, locale, and ref are set' do
      command.set_repo_name(repo_name)
      command.set_locale(locales.first)
      command.set_ref('HEAD')
      expect(command).to be_valid
    end
  end

  context '#execute' do
    let(:meta_key) { 'cool.meta_key' }
    let(:key) { 'cool key' }

    before do
      command.set_repo_name(repo_name)
        .set_locale(locales.first)
        .set_ref('HEAD')
        .set_key(key)
        .set_meta_key(meta_key)
    end

    it 'adds a translation to the datastore' do

    end
  end


end
