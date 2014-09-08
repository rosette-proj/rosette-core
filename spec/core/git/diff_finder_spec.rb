# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.lib.ObjectId'

describe DiffFinder do
  let(:repo_name) { 'double_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:repo) { Repo.from_path(fixture.repo_fixture.working_dir.join('.git').to_s) }
  let(:rev_walk) { RevWalk.new(repo.jgit_repo) }
  let(:diff_finder) { DiffFinder.new(repo.jgit_repo, rev_walk) }

  let(:revs) do
    fixture.each_commit.map do |fixture_commit|
      rev_walk.parseCommit(ObjectId.fromString(fixture_commit.sha))
    end
  end

  let(:first_file_contents) do
    "I'm a little teapot\n" +
    "The green albatross flitters in the moonlight\n"
  end

  let(:second_file_contents) do
    "Chatanooga Choo Choo\n" +
    "Diamonds are a girl's best friend.\n" +
    "Cash for the merchandise; cash for the fancy goods.\n" +
    "I'm in Spañish.\n"
  end

  describe '#diff' do
    it 'returns the diff between the first two commits' do
      diff_finder.diff(revs.first, revs.last).tap do |diff|
        expect(diff.size).to eq(1)
        expect(diff.first.getNewPath).to eq('second_file.txt')
        expect(diff_finder.read_new_entry(diff.first)).to eq(second_file_contents)
      end
    end
  end

  describe '#diff_with_parent' do
    it 'returns the diff between the first two commits (just as a regular diff would do)' do
      diff_finder.diff_with_parent(revs.last).tap do |diff|
        expect(diff.size).to eq(1)
        expect(diff.first.getNewPath).to eq('second_file.txt')
        expect(diff_finder.read_new_entry(diff.first)).to eq(second_file_contents)
      end
    end

    it "returns the diff successfully if the rev doesn't have a parent" do
      diff_finder.diff_with_parent(revs.first).tap do |diff|
        expect(diff.size).to eq(1)
        expect(diff.first.getNewPath).to eq('first_file.txt')
        expect(diff_finder.read_new_entry(diff.first)).to eq(first_file_contents)
      end
    end
  end
end
