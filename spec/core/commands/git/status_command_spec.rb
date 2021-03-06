# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Core::Commands

describe StatusCommand do
  let(:repo_name) { 'double_commit' }
  let(:locales) { %w(es de-DE ja-JP) }

  let(:commit_log_locale_model) do
    Rosette::DataStores::InMemoryDataStore::CommitLogLocale
  end

  let(:commit_log_model) do
    Rosette::DataStores::InMemoryDataStore::CommitLog
  end

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_locales(locales)
    end
  end

  let(:repo_config) { fixture.config.get_repo(repo_name) }
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
    let(:status) { Rosette::DataStores::PhraseStatus::NOT_SEEN }

    before do
      commit(fixture.config, repo_name, head_ref(fixture.repo))
      command.set_ref('HEAD')
      command.set_repo_name(repo_name)

      repo_config.repo.each_commit do |rev_commit|
        branch_name = BranchUtils.derive_branch_name(
          rev_commit.getId.name, repo_config.repo
        )

        fixture.config.datastore.add_or_update_commit_log(
          repo_name,
          rev_commit.getId.name,
          nil, status,
          phrase_count,
          branch_name
        )

        locales.each do |locale|
          fixture.config.datastore.add_or_update_commit_log_locale(
            rev_commit.getId.name, locale, translated_count
          )
        end
      end
    end

    it 'returns the translation status for a commit' do
      status_result = command.execute
      expect(status_result[:commit_id]).to eq(head_ref(fixture.repo))
      expect(status_result[:status]).to eq(Rosette::DataStores::PhraseStatus::NOT_SEEN)
      expect(status_result[:phrase_count]).to eq(phrase_count * 2)

      locales_result = locales.each_with_object({}) do |locale, ret|
        ret[locale] = {
          percent_translated: (translated_count.to_f / phrase_count).round(2),
          translated_count: translated_count * 2
        }
      end

      expect(status_result[:locales]).to eq(locales_result)
    end

    it 'fills in translation data for missing locales' do
      index_to_delete = commit_log_locale_model.entries.delete_if do |commit_log|
        commit_log.locale == locales.first
      end

      status_result = command.execute
      untranslated_locale = status_result[:locales][locales.first]

      expect(untranslated_locale).to eq({
        percent_translated: 0.0,
        translated_count: 0
      })
    end

    context 'with FINALIZED commit logs' do
      let(:status) { Rosette::DataStores::PhraseStatus::FINALIZED }

      it 'returns a FINALIZED status' do
        expect(command.execute[:status]).to eq(
          Rosette::DataStores::PhraseStatus::FINALIZED
        )
      end
    end

    context 'with one NOT_SEEN commit and one PUSHED commit' do
      before do
        fixture.config.datastore.add_or_update_commit_log(
          repo_name,
          head_ref(fixture.repo),
          nil, Rosette::DataStores::PhraseStatus::PUSHED,
          phrase_count
        )
      end

      it 'returns a NOT_SEEN status' do
        expect(command.execute[:status]).to eq(
          Rosette::DataStores::PhraseStatus::NOT_SEEN
        )
      end
    end

    context 'with an unprocessed commit' do
      before do
        commit_log_locale_model.entries.clear
        commit_log_model.entries.clear
      end

      it 'returns a NOT_FOUND status' do
        expect(command.execute[:status]).to eq(
          Rosette::DataStores::PhraseStatus::NOT_FOUND
        )
      end
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
end
