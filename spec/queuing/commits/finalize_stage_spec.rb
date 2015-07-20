# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores
include Rosette::Core

describe FinalizeStage do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
      repo_config.add_locales(%w(pt-BR ja-JP))
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  let(:commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::PUSHED,
      repo_name: repo_name,
      commit_id: commit_id,
      phrase_count: 10,
      commit_datetime: nil,
      branch_name: 'refs/heads/master'
    )
  end

  let(:stage) do
    FinalizeStage.new(rosette_config, repo_config, logger, commit_log)
  end

  describe '#execute!' do
    before(:each) do
      allow(repo_config.tms).to receive(:status).and_return(
        TranslationStatus.new(commit_log.phrase_count).tap do |status|
          repo_config.locales.each do |locale|
            status.add_locale_count(locale.code, locale_count)
          end
        end
      )
    end

    context 'with a not fully translated status' do
      let(:locale_count) { commit_log.phrase_count - 1 }

      it "creates commit log locale entries and doesn't update the status" do
        expect(repo_config.tms).to_not receive(:finalize)
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::PUSHED)
        entries = InMemoryDataStore::CommitLogLocale.map(&:translated_count)
        entries.each { |e| expect(e).to eq(commit_log.phrase_count - 1) }
      end
    end

    context 'with a fully translated status' do
      let(:locale_count) { commit_log.phrase_count }

      it 'calls finalize on the tms, updates the status, and creates entries' do
        expect(repo_config.tms).to receive(:finalize)
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::FINALIZED)
        entries = InMemoryDataStore::CommitLogLocale.map(&:translated_count)
        entries.each { |e| expect(e).to eq(commit_log.phrase_count) }
      end
    end
  end
end
