# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe RepoSnapshotCommand do
  let(:repo_name) { 'double_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:command) { RepoSnapshotCommand.new(fixture.config) }

  context 'validation' do
    it 'requires a valid repo name' do
      command.set_ref('HEAD')
      expect(command).to_not be_valid
    end

    it 'requires a valid ref' do
      command.set_repo_name(repo_name)
      expect(command).to_not be_valid
    end

    it 'should be valid if given a valid repo name and ref' do
      command.set_repo_name(repo_name)
      command.set_ref('HEAD')
      expect(command).to be_valid
    end
  end

  context '#execute' do
    let(:commits) do
      fixture.repo.git("log --pretty=format:'%H'").split("\n")
    end

    before do
      command.set_repo_name(repo_name)
      expect(commits.size).to eq(2)
    end

    it 'returns a snapshot with one entry per file' do
      expected_snapshot = {
        'first_file.txt' => commits.last,
        'second_file.txt' => commits.first
      }

      actual_snapshot = command
        .set_ref(commits.first)
        .execute

      expect(actual_snapshot).to eq(expected_snapshot)
    end

    it 'returns a snapshot that only contains the specified paths' do
      expected_snapshot = {
        'first_file.txt' => commits.last
      }

      actual_snapshot = command
        .set_ref(commits.first)
        .set_paths(['first_file.txt'])
        .execute

      expect(actual_snapshot).to eq(expected_snapshot)
    end
  end
end
