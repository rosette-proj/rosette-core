# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands
include Rosette::DataStores

describe RequeueCommitCommand do
  let(:repo_name) { 'single_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_queue('test')
      config.use_datastore('in-memory')
    end
  end

  let(:queue) { Rosette::Queuing::TestQueue::Queue }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }
  let(:rosette_config) { fixture.config }
  let(:command) do
    RequeueCommitCommand.new(rosette_config)
      .set_repo_name(repo_name)
      .set_commit_id(commit_id)
  end

  describe '#execute' do
    let!(:commit_log) do
      InMemoryDataStore::CommitLog.create(
        repo_name: repo_name, commit_id: commit_id,
        status: PhraseStatus::EXTRACTED, phrase_count: 0,
        branch_name: 'refs/remotes/origin/master',
        commit_datetime: Time.now
      )
    end

    it 'enqueues the commit' do
      expect { command.execute }.to(
        change { queue.list.size }.from(0).to(1)
      )

      expect(queue.list.first.commit_id).to eq(commit_id)
      expect(commit_log.status).to eq(PhraseStatus::NOT_FOUND)
    end
  end
end
