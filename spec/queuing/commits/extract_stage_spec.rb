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
      status: PhraseStatus::FETCHED,
      repo_name: repo_name,
      commit_id: commit_id,
      phrase_count: 0,
      commit_datetime: nil
    )
  end

  let(:stage) do
    ExtractStage.new(rosette_config, repo_config, logger, commit_log)
  end

  describe '#execute!' do
    it 'extracts phrases' do
      stage.execute!
      phrases = InMemoryDataStore::Phrase.entries.map(&:key)
      expect(phrases).to include("I'm a little teapot")
      expect(phrases).to include("Diamonds are a girl's best friend.")
      expect(phrases).to include(' test string 1')
    end

    it 'updates the commit log status' do
      stage.execute!
      expect(commit_log.status).to eq(PhraseStatus::UNTRANSLATED)
    end

    it "updates the status to MISSING if the commit doesn't exist" do
      fixture.repo.git('reset --hard HEAD')
      fixture.repo.create_file('testfile.txt') { |f| f.write('foo') }
      fixture.repo.add_all
      fixture.repo.commit('Test commit')

      commit_log.commit_id = fixture.repo.git('rev-parse HEAD').strip

      fixture.repo.git('reset --hard HEAD~1')
      fixture.repo.git('reflog expire --expire=now --all')
      fixture.repo.git('fsck --unreachable')
      fixture.repo.git('prune -v')

      stage.execute!
      expect(commit_log.status).to eq(PhraseStatus::MISSING)
    end
  end
end
