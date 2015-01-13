# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe SnapshotCommand do
  let(:repo_name) { 'double_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:command) { SnapshotCommand.new(fixture.config) }

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

      commits.each do |commit_id|
        commit(fixture.config, repo_name, commit_id)
      end
    end

    it 'returns a list of the phrases from both files' do
      phrases = command
        .set_ref(commits.first)
        .execute
        .map(&:key)

      expect(phrases.sort).to eq([
        "I'm a little teapot",
        'The green albatross flitters in the moonlight',
        'Chatanooga Choo Choo',
        "Diamonds are a girl's best friend.",
        'Cash for the merchandise; cash for the fancy goods.',
        "I'm in Spañish."
      ].sort)
    end

    it 'returns a list of the phrases only at the specified paths' do
      phrases = command
        .set_ref(commits.first)
        .set_paths(['first_file.txt'])
        .execute
        .map(&:key)

      expect(phrases.sort).to eq([
        "I'm a little teapot",
        'The green albatross flitters in the moonlight'
      ].sort)
    end
  end

  def commit(config, repo_name, ref)
    CommitCommand.new(config)
      .set_repo_name(repo_name)
      .set_ref(ref)
      .execute
  end
end
