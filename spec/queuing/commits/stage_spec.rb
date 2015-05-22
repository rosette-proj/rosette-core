# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores

describe Stage do
  let(:stage_class) { Class.new(Stage) }
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { '123abc' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  let(:pulling_commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::PULLING, repo_name: repo_name, commit_id: commit_id
    )
  end

  let(:pending_commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::PENDING, repo_name: repo_name, commit_id: commit_id
    )
  end

  before(:each) do
    stage_class.accepts(PhraseStatus::PENDING)
  end

  describe '.accepts?' do
    it 'returns true if the stage accepts the given commit log' do
      expect(stage_class.accepts?(pending_commit_log)).to be_truthy
    end

    it 'returns false if the stage does not accept the given commit log' do
      expect(stage_class.accepts?(pulling_commit_log)).to be_falsy
    end
  end

  describe '.for_commit_log' do
    it "returns nil if the commit log isn't accepted" do
      result = stage_class.for_commit_log(
        pulling_commit_log, rosette_config, logger
      )

      expect(result).to be_nil
    end

    it 'wraps the commit log in a stage instance' do
      result = stage_class.for_commit_log(
        pending_commit_log, rosette_config, logger
      )

      expect(result).to be_a(stage_class)
      expect(result.rosette_config).to eq(rosette_config)
      expect(result.repo_config).to_not be_nil
      expect(result.logger).to eq(logger)
      expect(result.commit_log).to eq(pending_commit_log)
    end
  end

  describe '#to_job' do
    let(:stage) do
      stage_class.new(rosette_config, repo_config, logger, pending_commit_log)
    end

    it 'converts the stage to a job' do
      expect(stage.to_job).to be_a(CommitJob)
    end
  end
end
