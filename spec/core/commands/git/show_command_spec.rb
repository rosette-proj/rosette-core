# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe ShowCommand do
  let(:repo_name) { 'four_commits' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.add_extractor('test/test') do |extractor_config|
        extractor_config.set_conditions do |conditions|
          conditions.match_regex(//)
        end
      end
    end
  end

  let(:command) { ShowCommand.new(fixture.config) }

  context 'validations' do
    it 'requires a valid repo name' do
      command.set_ref('HEAD')
      expect(command).to_not be_valid
    end

    it 'requires a ref' do
      command.set_repo_name(repo_name)
      expect(command).to_not be_valid
    end

    it 'should be valid if the repo name and ref are set' do
      command.set_repo_name(repo_name)
      command.set_ref('HEAD')
      expect(command).to be_valid
    end
  end

  context '#execute' do
    before do
      fixture.each_commit do |fixture_commit|
        commit(fixture.config, repo_name, fixture_commit.sha)
      end

      command.set_repo_name(repo_name)
    end

    context 'when a phrase gets added' do
      let(:new_key) { 'Yo momma wears army boots' }

      before do
        fixture.repo.create_file('new_file.txt') do |f|
          f.write(new_key)
        end

        fixture.repo.add_all
        fixture.repo.commit('Adding new_file.txt')
        commit(fixture.config, repo_name, head_ref(fixture.repo))
      end

      it 'returns a diff that contains the added phrase' do
        show_hash = command.set_ref(head_ref(fixture.repo)).execute
        expect(show_hash[:added].size).to eq(1)
        expect(show_hash[:added].first.phrase.key).to eq(new_key)
      end
    end

    context 'when phrases get removed' do
      before do
        fixture.repo.git('rm -f file1.txt')
        fixture.repo.git('rm -f file2.txt')
        fixture.add_all
        fixture.repo.commit('Remove file1.txt and file2.txt')

        commit(fixture.config, repo_name, head_ref(fixture.repo))
      end

      it 'returns a diff that contains the deleted phrases' do
        show_hash = command.set_ref(head_ref(fixture.repo)).execute
        expect(show_hash[:removed].size).to eq(2)
        expect(show_hash[:removed].map { |entry| entry.phrase.key }.sort).to eq([
          'bar', 'foo'
        ])
      end
    end

    context "when the parent hasn't been processed yet" do
      before do
        command.set_ref(head_ref(fixture.repo))
        parent_commit_id = fixture.repo.git('rev-parse HEAD~1').strip

        Rosette::DataStores::InMemoryDataStore::CommitLog.entries.reject! do |entry|
          entry.commit_id == parent_commit_id
        end
      end

      it 'raises an error in strict mode' do
        expect { command.execute }.to raise_error(
          Rosette::Core::Commands::Errors::UnprocessedCommitError
        )
      end

      it 'uses the most recently processed commit in non-strict mode' do
        show_hash = command.set_strict(false).execute
        expect(show_hash[:added].map { |entry| entry.phrase.key}.sort).to eq([
          'goo'
        ])
      end
    end
  end

  def head_ref(repo)
    repo.git('rev-parse HEAD').strip
  end

  def commit(config, repo_name, ref)
    CommitCommand.new(config)
      .set_repo_name(repo_name)
      .set_ref(ref)
      .execute

    fixture.config.datastore.add_or_update_commit_log(
      repo_name, ref, nil
    )
  end
end
