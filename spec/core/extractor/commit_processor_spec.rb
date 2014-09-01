# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe CommitProcessor do
  let(:repo_fixture) do
  end

  let(:config) do
    Configurator.new.tap do |config|
      config.add_repo('rosette-test') do |repo|
        repo.set_path(repo_fixture.working_dir)
      end
    end
  end

  describe '#process_each_phrase' do
  end
end
