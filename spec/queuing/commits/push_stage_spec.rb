# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores

describe PushStage do
  let(:repo_name) { 'single_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      repo_config.use_tms('test')
      config.use_datastore('in-memory')
      config.use_queue('test') do |queue_config|
        queue_config.enable_queue('commits')
      end
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  describe '#execute!' do
    context 'with a single commit' do
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

      let(:stage) do
        PushStage.new(rosette_config, repo_config, logger, commit_log)
      end

      let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

      before(:each) do
        args = [rosette_config, repo_config, logger, commit_log]
        ExtractStage.new(*args).execute!
      end

      it 'updates the status to FINALIZED when no phrases are found' do
        expect(stage).to receive(:phrases).and_return([])
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::FINALIZED)
      end

      it 'stores the phrases in the repository' do
        stage.execute!
        phrases = repo_config.tms.stored_phrases[commit_id].map(&:key)
        expect(phrases).to include('The green albatross flitters in the moonlight')
        expect(phrases).to include('Chatanooga Choo Choo')
        expect(phrases).to include(' test string 1')
      end

      it 'updates the commit log status' do
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::PUSHED)
      end

      it "updates the status to MISSING if one of the objects doesn't exist" do
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

  context 'with a git branch' do
    before(:each) do
      fixture.repo.create_branch('my_branch')

      fixture.repo.create_file('testfile.txt') { |f| f.write('first') }
      fixture.repo.add_all
      fixture.repo.commit('Test commit')

      fixture.repo.create_file('anothertestfile.txt') { |f| f.write('second') }
      fixture.repo.add_all
      fixture.repo.commit('Another test commit')

      fixture.repo.each_commit_id do |commit_id|
        commit_log = InMemoryDataStore::CommitLog.create(
          status: PhraseStatus::FETCHED,
          repo_name: repo_name,
          commit_id: commit_id,
          phrase_count: 0,
          commit_datetime: nil,
          branch_name: 'refs/heads/my_branch'
        )

        args = [rosette_config, repo_config, logger, commit_log]
        ExtractStage.new(*args).execute!
      end
    end

    context 'with phrase storage granularity set to BRANCH' do
      before(:each) do
        queue = rosette_config.queue.configurator.get_queue_config('commits')
        queue.set_phrase_storage_granularity(PhraseStorageGranularity::BRANCH)
      end

      let(:commit_log) do
        InMemoryDataStore::CommitLog.entries.last
      end

      let(:stage) do
        PushStage.new(rosette_config, repo_config, logger, commit_log)
      end

      describe '#execute' do
        it 'pushes all the phrases in the branch' do
          stage.execute!
          phrases = repo_config.tms.stored_phrases[commit_log.commit_id]
          expect(phrases.map(&:key)).to eq(%w(second first))
        end
      end
    end
  end
end
