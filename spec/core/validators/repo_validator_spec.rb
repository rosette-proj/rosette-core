# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Core::Validators

describe RepoValidator do
  let(:repo_name) { 'double_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:validator) { RepoValidator.new }

  let(:config) do
    config = Configurator.new
    config.add_repo(repo_name) do |repo_config|
      repo_config.set_path(fixture.working_dir.join('.git').to_s)
    end
    config
  end

  describe '#valid?' do
    it 'returns true if the repo exists' do
      expect(validator.valid?(repo_name, repo_name, config)).to be_truthy
    end

    it "returns false if the repo doesn't exist" do
      expect(validator.valid?('foobar', repo_name, config)).to be_falsy
    end
  end
end
