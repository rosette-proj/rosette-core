# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::Queuing
include Rosette::DataStores

describe CommitConductor do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      config.use_queue('test')
    end
  end

  let(:rosette_config) { fixture.config }
  let(:logger) { NullLogger.new }

  let(:conductor) { CommitConductor.new(rosette_config, repo_name, logger) }

  before(:each) do
    allow(CommitConductor).to receive(:stage_classes).and_return(
      [FakeCommitStage]
    )
  end

  describe '#enqueue' do
    it 'adds a new commit job to the queue' do
      expect { conductor.enqueue(commit_id) }.to(
        change { TestQueue::Queue.list.size }.from(0).to(1)
      )

      job = TestQueue::Queue.list.first
      expect(job.repo_name).to eq(repo_name)
      expect(job.commit_id).to eq(commit_id)
    end
  end

  describe '#advance' do
    let(:commit_log) do
      InMemoryDataStore::CommitLog.create(
        status: PhraseStatus::FETCHED,
        repo_name: repo_name,
        commit_id: commit_id,
        phrase_count: 0,
        commit_datetime: nil,
        branch_name: 'refs/heads/master'
      )
    end

    it 'finds the correct stage, executes it, and enqueues the next stage' do
      expect { conductor.advance(commit_log) }.to(
        change { TestQueue::Queue.list.size }.from(0).to(1)
      )

      expect(commit_log.status).to eq('fake_stage_updated_me')
    end

    it 'does not enqueue a new job if the commit is finished' do
      expect(conductor).to receive(:finished?).and_return(true)

      expect { conductor.advance(commit_log) }.to_not(
        change { TestQueue::Queue.list.size }.from(0)
      )
    end
  end
end
