# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Core::Validators

describe EncodingValidator do
  let(:repo_name) { 'double_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:validator) { EncodingValidator.new }

  let(:config) do
    config = Configurator.new
    config.add_repo(repo_name) do |repo_config|
      repo_config.set_path(fixture.working_dir.join('.git').to_s)
    end
    config
  end

  describe '#valid?' do
    it 'returns true if the encoding is valid' do
      expect(validator.valid?('UTF-8', repo_name, config)).to be_truthy
    end

    it 'returns false if the encoding is not valid' do
      expect(validator.valid?('FOO', repo_name, config)).to be_falsy
    end
  end
end
