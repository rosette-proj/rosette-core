# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe Configurator do
  let(:config) { Configurator.new }

  describe '#add_repo' do
    it 'yields and adds a repo config' do
      config.add_repo('foo') do |repo_config|
        expect(repo_config).to be_a(Rosette::Core::RepoConfig)
        expect(repo_config.name).to eq('foo')
      end
    end
  end

  describe '#get_repo' do
    it 'returns the repo by name' do
      config.add_repo('foo') {}
      config.get_repo('foo').tap do |repo|
        expect(repo.name).to eq('foo')
      end
    end
  end

  describe '#use_datastore' do
    it 'attempts to look up the datastore constant if passed a string' do
      config.use_datastore('test')
      expect(config.datastore).to be_a(Rosette::DataStores::TestDataStore)
    end

    it 'uses the passed in value directly if not passed a string (should be a constant, fyi)' do
      config.use_datastore(Rosette::DataStores::TestDataStore)
      expect(config.datastore).to be_a(Rosette::DataStores::TestDataStore)
    end

    it "raises an error if the object passed isn't a String or Class" do
      expect(lambda { config.use_datastore(1) }).to raise_error(ArgumentError)
    end

    it "raises an error if the datastore couldn't be looked up" do
      expect(lambda { config.use_datastore('foo') }).to raise_error(ArgumentError)
    end
  end
end
