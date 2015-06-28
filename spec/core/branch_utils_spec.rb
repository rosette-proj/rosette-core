# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::DataStores

describe BranchUtils do
  let(:repo_name) { 'single_commit' }

  # note: the fixture will only be used for its datastore, the actual contents
  # of the underlying repository aren't important
  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_locales(%w(ko-KR ja-JP pt-BR))
    end
  end

  let(:datastore) { fixture.config.datastore }
  let(:commit_log) { InMemoryDataStore::CommitLog }
  let(:commit_log_locale) { InMemoryDataStore::CommitLogLocale }

  let(:locale_statuses_hash) do
    {
      'ko-KR' => { translated_count: 5, percent_translated: 0.5 },
      'ja-JP' => { translated_count: 9, percent_translated: 0.9 }
    }.freeze
  end

  before(:each) do
    commit_log.create(
      repo_name: repo_name, phrase_count: 5, commit_id: 'abc123',
      status: PhraseStatus::FETCHED
    )

    commit_log_locale.create(
      commit_id: 'abc123', locale: 'ko-KR', translated_count: 5
    )

    commit_log_locale.create(
      commit_id: 'abc123', locale: 'ja-JP', translated_count: 4
    )

    commit_log.create(
      repo_name: repo_name, phrase_count: 5, commit_id: 'def456',
      status: PhraseStatus::PUSHED
    )

    commit_log_locale.create(
      commit_id: 'def456', locale: 'ja-JP', translated_count: 5
    )
  end

  describe 'derive_status_from' do
    it 'returns the lowest-ranked status' do
      status = BranchUtils.derive_status_from(commit_log.entries)
      expect(status).to eq(PhraseStatus::FETCHED)
    end
  end

  describe 'derive_phrase_count_from' do
    it 'returns a sum of all phrase counts' do
      count = BranchUtils.derive_phrase_count_from(commit_log.entries)
      expect(count).to eq(10)
    end
  end

  describe 'derive_locale_statuses_from' do
    it 'returns a hash of locale statuses and translation percentages' do
      locale_statuses = BranchUtils.derive_locale_statuses_from(
        commit_log.entries, repo_name, datastore
      )

      expect(locale_statuses).to eq(locale_statuses_hash)
    end

    it "doesn't choke when phrase count is zero (possible divide by zero)" do
      commit_log.entries.each do |entry|
        entry.phrase_count = 0
      end

      locale_statuses = BranchUtils.derive_locale_statuses_from(
        commit_log.entries, repo_name, datastore
      )

      expect(locale_statuses.keys).to contain_exactly('ko-KR', 'ja-JP')

      locale_statuses.each do |_, status|
        expect(status[:percent_translated]).to eq(0.0)
      end
    end
  end

  describe 'fill_in_missing_locales' do
    it 'adds missing locales to the locale statuses hash' do
      locale_statuses = BranchUtils.fill_in_missing_locales(
        fixture.config.get_repo(repo_name).locales, locale_statuses_hash
      )

      expect(locale_statuses).to eq(
        locale_statuses_hash.merge(
          'pt-BR' => {
            translated_count: 0, percent_translated: 0.0
          }
        )
      )
    end
  end
end
