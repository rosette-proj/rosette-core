# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::Queuing
include Rosette::DataStores

describe PullStage do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      config.use_queue('test')
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { fixture.config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  let(:commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::FETCHED,
      repo_name: repo_name,
      commit_id: commit_id,
      phrase_count: 0,
      commit_datetime: nil
    )
  end

  let(:job) do
    CommitJob.new(repo_name, commit_id, commit_log.status)
  end

  before(:each) do
    allow(CommitConductor).to receive(:stage_classes).and_return([FakeStage])
  end

  describe 'from_stage' do
    it 'instantiates a job with information from the stage' do
      stage = FetchStage.new(rosette_config, repo_config, logger, commit_log)
      CommitJob.from_stage(stage).tap do |job|
        expect(job.repo_name).to eq(repo_name)
        expect(job.commit_id).to eq(commit_id)
        expect(job.status).to eq(commit_log.status)
      end
    end
  end

  describe '#to_args' do
    it 'creates an array of serializable arguments' do
      expect(job.to_args).to eq([repo_name, commit_id, commit_log.status])
    end
  end

  describe '#work' do
    it 'looks up the commit log and advances it to the next stage' do
      expect { job.work(rosette_config, logger) }.to(
        change { TestQueue::Queue.list.size }
      )

      expect(commit_log.status).to eq('fake_stage_updated_me')
    end

    it 'creates a commit log if one does not already exist' do
      InMemoryDataStore::CommitLog.entries.clear

      expect { job.work(rosette_config, logger) }.to(
        change { InMemoryDataStore::CommitLog.entries.size }.from(0).to(1)
      )

      entry = InMemoryDataStore::CommitLog.entries.first
      expect(entry.status).to eq('fake_stage_updated_me')
    end
  end
end
