# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores

describe FetchStage do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  let(:commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::NOT_SEEN,
      repo_name: repo_name,
      commit_id: commit_id,
      phrase_count: 0,
      commit_datetime: nil
    )
  end

  let(:stage) do
    FetchStage.new(rosette_config, repo_config, logger, commit_log)
  end

  let(:git) { double(:git) }
  let(:git_message_chain) { [:fetch, :setRemote, :setRemoveDeletedRefs] }

  before(:each) do
    stage.instance_variable_set(:'@git', git)
  end

  describe '#execute!' do
    it 'runs a git fetch on the repo' do
      allow(git).to(
        receive_message_chain(git_message_chain).and_return(git)
      )

      expect(git).to receive(:call)
      stage.execute!
    end

    it 'updates the commit log status' do
      allow(git).to(
        receive_message_chain(git_message_chain).and_return(git)
      )

      allow(git).to receive(:call)

      stage.execute!
      expect(commit_log.status).to eq(PhraseStatus::FETCHED)
    end
  end
end
