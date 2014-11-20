# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Core::Validators

describe CommitValidator do
  let(:repo_name) { 'double_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:validator) { CommitValidator.new }

  let(:config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.set_path(fixture.working_dir.join('.git').to_s)
      end
    end
  end

  let(:shas) do
    fixture.git('rev-list --all').split("\n")
  end

  describe '#valid?' do
    it 'returns true if the commit exists' do
      shas.each do |sha|
        expect(validator.valid?(sha, repo_name, config)).to be_truthy
      end
    end

    it "returns false if the commit doesn't exist" do
      expect(validator.valid?('123abc', repo_name, config)).to be_falsy
    end

    it "returns false if the repo can't be found" do
      expect(validator.valid?(shas.first, 'foobar', config)).to be_falsy
    end
  end
end
