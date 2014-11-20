# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::Core::Validators

describe LocaleValidator do
  let(:repo_name) { 'double_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:validator) { LocaleValidator.new }

  let(:config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.set_path(fixture.working_dir.join('.git').to_s)
        repo_config.add_locale('es-MX')
      end
    end
  end

  describe '#valid?' do
    it 'returns true if the locale exists in the list of configured locales' do
      expect(validator.valid?('es-MX', repo_name, config)).to be_truthy
    end

    it "returns false if the locale doesn't exist in the list of configured locales" do
      expect(validator.valid?('xx', repo_name, config)).to be_falsy
    end
  end
end
