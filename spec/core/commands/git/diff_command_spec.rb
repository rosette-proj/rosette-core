# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe DiffCommand do
  let(:repo_name) { 'single_commit' }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
    end
  end

  let(:diff_command) { DiffCommand.new(fixture.config) }

  context 'validation' do
    it 'requires a valid repo name' do
      diff_command.set_head_ref('HEAD')
      diff_command.set_diff_point_ref('HEAD')
      expect(diff_command).to_not be_valid
    end

    it 'requires a head ref' do
      diff_command.set_repo_name(repo_name)
      diff_command.set_diff_point_ref('HEAD')
      expect(diff_command).to_not be_valid
    end

    it 'requires a diff point ref' do
      diff_command.set_repo_name(repo_name)
      diff_command.set_head_ref('HEAD')
      expect(diff_command).to_not be_valid
    end

    it 'should be valid if the repo name, head ref, and diff point ref are set' do
      diff_command.set_repo_name(repo_name)
      diff_command.set_head_ref('HEAD')
      diff_command.set_diff_point_ref('HEAD')
      expect(diff_command).to be_valid
    end
  end

  context 'with valid options' do
    before(:each) do
      diff_command.set_diff_point_ref(head_ref)
      diff_command.set_repo_name(repo_name)
      commit(fixture.config, repo_name, head_ref)
    end

    describe '#execute' do
      let(:key) { 'Here is a test string' }

      context 'when a phrase is added to HEAD' do
        before do
          fixture.repo.create_file('test.txt') do |writer|
            writer.write(key)
          end

          fixture.repo.add_all
          fixture.repo.commit('Commit message')

          commit(fixture.config, repo_name, head_ref)
          diff_command.set_head_ref(head_ref)
        end

        it 'returns a diff that contains the added phrase' do
          added_phrases = diff_command.execute[:added]
          expect(added_phrases.size).to eq(1)
          expect(added_phrases.first.phrase.key).to eq(key)
        end
      end

      context 'when a phrase is removed from HEAD' do
        before do
          fixture.repo.git('rm -f first_file.txt')
          fixture.add_all
          fixture.repo.commit('Remove file.txt')

          commit(fixture.config, repo_name, head_ref)
          diff_command.set_head_ref(head_ref)
        end

        it 'returns a diff that contains the removed phrases' do
          removed_phrases = diff_command.execute[:removed]
          expect(removed_phrases.size).to eq(2)
          expect(removed_phrases.map { |diff_entry| diff_entry.phrase.key }).to eq([
            "I'm a little teapot",
            "The green albatross flitters in the moonlight"
          ])
        end
      end

      context 'with a file that contains metakeys' do
        let(:file_path) { fixture.working_dir.join('folder/with_metakeys.txt') }
        let(:phrases) { File.read(file_path).split("\n") }

        context 'when a phrase is modified on HEAD' do
          let(:new_key) { 'Here is a new string' }

          before do
            first_phrase = phrases.first.split(':')
            @meta_key = first_phrase[0]
            @old_key = first_phrase[1]
            first_phrase[1] = new_key
            phrases[0] = first_phrase.join(':')

            File.open(file_path, 'w+') do |f|
              f.write(phrases.join("\n"))
            end

            fixture.repo.add_all
            fixture.repo.commit('Modified a string')

            commit(fixture.config, repo_name, head_ref)
            diff_command.set_head_ref(head_ref)
          end

          it 'returns a diff that contains the modified phrase' do
            modified_phrases = diff_command.execute[:modified]
            expect(modified_phrases.size).to eq(1)
            modified_phrase = modified_phrases.first.phrase
            expect(modified_phrases.first.old_phrase.key).to eq(@old_key)
            expect(modified_phrase.meta_key).to eq(@meta_key)
            expect(modified_phrase.key).to eq(new_key)
          end
        end

        context 'when a phrase is added to HEAD' do
          let(:new_meta_key) { 'cool.metakey' }
          let(:new_key) { 'my new key' }

          before do
            phrases << new_meta_key + ':' + new_key
            File.open(file_path, 'w+') do |f|
              f.write(phrases.join("\n"))
            end

            fixture.repo.add_all
            fixture.repo.commit('Added a string')

            commit(fixture.config, repo_name, head_ref)
            diff_command.set_head_ref(head_ref)
          end

          it 'returns a diff that contains the added phrase' do
            added_phrases = diff_command.execute[:added]
            expect(added_phrases.size).to eq(1)
            expect(added_phrases.first.phrase.meta_key).to eq(new_meta_key)
            expect(added_phrases.first.phrase.key).to eq(new_key)
          end
        end

        context 'when a phrase is removed from HEAD' do
          before do
            first_phrase = phrases.shift.split(':')
            @meta_key = first_phrase[0]
            @key = first_phrase[1]

            File.open(file_path, 'w+') do |f|
              f.write(phrases.join("\n"))
            end

            fixture.repo.add_all
            fixture.repo.commit('Removed a string')

            commit(fixture.config, repo_name, head_ref)
            diff_command.set_head_ref(head_ref)
          end

          it 'returns a diff that contains the removed phrase' do
            removed_phrases = diff_command.execute[:removed]
            expect(removed_phrases.size).to eq(1)
            expect(removed_phrases.first.phrase.meta_key).to eq(@meta_key)
            expect(removed_phrases.first.phrase.key).to eq(@key)
          end

        end
      end
    end
  end

  def head_ref
    fixture.repo.git('rev-parse HEAD').strip
  end

  def commit(config, repo_name, ref)
    CommitCommand.new(config)
      .set_repo_name(repo_name)
      .set_ref(ref)
      .execute
  end
end
