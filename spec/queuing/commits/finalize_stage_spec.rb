# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores

describe FinalizeStage do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
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
      phrase_count: 0,
      commit_datetime: nil
    )
  end

  let(:stage) do
    FinalizeStage.new(rosette_config, repo_config, logger, commit_log)
  end

  describe '#execute!' do
    it 'calls finalize on the tms' do
      expect(repo_config.tms).to receive(:finalize)
      stage.execute!
    end

    it 'updates the commit log status' do
      stage.execute!
      expect(commit_log.status).to eq(PhraseStatus::FINALIZED)
    end
  end
end
