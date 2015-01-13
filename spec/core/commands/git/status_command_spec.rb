# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe StatusCommand do
  let(:repo_name) { 'single_commit' }
  let(:locales) { %w(es de-DE ja-JP) }
  let(:commit_log_locale_model) { Rosette::DataStores::InMemoryDataStore::CommitLogLocale }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_locales(locales)
    end
  end

  let(:command) { StatusCommand.new(fixture.config) }

  context 'validations' do
    it 'requires a valid repo name' do
      command.set_ref('HEAD')
      expect(command).to_not be_valid
    end

    it 'requires a ref' do
      command.set_repo_name(repo_name)
      expect(command).to_not be_valid
    end

    it 'should be valid if the repo name and ref are set' do
      command.set_repo_name(repo_name)
      command.set_ref('HEAD')
      expect(command).to be_valid
    end
  end

  context '#execute' do
    let(:translated_count) { 6 }
    let(:phrase_count) { 8 }

    before do
      commit(fixture.config, repo_name, head_ref(fixture.repo))
      command.set_ref('HEAD')
      command.set_repo_name(repo_name)
      fixture.config.datastore.add_or_update_commit_log(
        repo_name,
        head_ref(fixture.repo),
        nil,
        Rosette::DataStores::PhraseStatus::UNTRANSLATED,
        phrase_count
      )

      locales.each do |locale|
        fixture.config.datastore.add_or_update_commit_log_locale(head_ref(fixture.repo), locale, translated_count)
      end
    end

    it 'returns the translation status for a commit' do
      status_result = command.execute
      expect(status_result[:commit_id]).to eq(head_ref(fixture.repo))
      expect(status_result[:status]).to eq(Rosette::DataStores::PhraseStatus::UNTRANSLATED)
      expect(status_result[:phrase_count]).to eq(phrase_count)

      locales_result = locales.map do |locale|
        {}.tap do |h|
          h[:locale] = locale
          h[:percent_translated] = (translated_count.to_f / phrase_count).round(2)
          h[:translated_count] = translated_count
        end
      end

      expect(sort_by_locale(status_result[:locales]) ).to eq(sort_by_locale(locales_result))
    end

    it 'fills in translation data for missing locales' do
      index_to_delete = commit_log_locale_model.find_index do |commit_log|
        commit_log.locale == locales.first
      end

      commit_log_locale_model.entries.delete_at(index_to_delete)
      status_result = command.execute
      untranslated_locale = status_result[:locales].find do |locale_status|
        locale_status[:locale] == locales.first
      end

      expect(untranslated_locale).to eq({
        locale: locales.first,
        percent_translated: 0.0,
        translated_count: 0
      })
    end

  end

  def head_ref(repo)
    repo.git('rev-parse HEAD').strip
  end

  def commit(config, repo_name, ref)
    CommitCommand.new(config)
      .set_repo_name(repo_name)
      .set_ref(ref)
      .execute
  end

  def sort_by_locale(locales_array)
    locales_array.sort { |a,b| a[:locale] <=> b[:locale] }
  end
end
