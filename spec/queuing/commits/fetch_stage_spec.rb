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
      commit_datetime: nil,
      branch_name: nil
    )
  end

  let(:stage) do
    FetchStage.new(rosette_config, repo_config, logger, commit_log)
  end

  let(:git) { double(:git) }
  let(:git_message_chain) { [:fetch, :setRemote, :setRemoveDeletedRefs] }

  before(:each) do
    stage.instance_variable_set(:'@git', git)

    allow(git).to(
      receive_message_chain(git_message_chain).and_return(git)
    )
  end

  describe '#execute!' do
    it 'runs a git fetch on the repo' do
      expect(git).to receive(:call)
      stage.execute!
    end

    context 'with a mocked fetch operation' do
      before(:each) do
        allow(git).to receive(:call)
      end

      it 'updates the commit log status' do
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::FETCHED)
      end

      it 'sets branch_name to the master branch if the commit exists in master' do
        remote_repo = TmpRepo.new

        # git doesn't allow you to push to the currently checked out branch, so
        # create a new branch to avoid an error
        remote_repo.git('checkout -b new_branch')
        fixture.repo.git("remote add origin #{remote_repo.working_dir}")
        fixture.repo.git('push origin HEAD')

        stage.execute!
        entry = InMemoryDataStore::CommitLog.entries.first
        expect(entry.branch_name).to eq('refs/remotes/origin/master')

        remote_repo.unlink
      end

      it 'sets branch_name to the first remote ref when creating a new commit log' do
        fixture.repo.git('checkout -b my_branch')
        fixture.repo.create_file('test.txt') do |writer|
          writer.write('test test test')
        end

        fixture.repo.add_all
        fixture.repo.commit('Commit message')

        remote_repo = TmpRepo.new
        fixture.repo.git("remote add origin #{remote_repo.working_dir}")
        fixture.repo.git('push origin HEAD')

        stage.execute!
        entry = InMemoryDataStore::CommitLog.entries.first
        expect(entry.branch_name).to eq('refs/remotes/origin/my_branch')

        remote_repo.unlink
      end
    end
  end
end
