# encoding: UTF-8

require 'jbundler'
require 'rspec'
require 'rosette/core'
require 'rosette/serializers'
require 'rosette/integrations'
require 'rosette/preprocessors'
require 'rosette/data_stores'
require 'repo-fixture'
require 'fileutils'
require 'pry-nav'

require 'spec/test_helpers'

RSpec.configure do |config|
  # build all fixtures before tests run
  TestHelpers::Fixtures.build_all

  def load_repo_fixture(*args)
    TestHelpers::Fixtures.load_repo_fixture(*args) do |config, repo_config|
      repo_config.add_extractor('test/test') do |ext|
        ext.match_file_extension('.txt')
      end

      yield config, repo_config if block_given?
    end
  end

  config.after(:each) do
    TestHelpers::Fixtures.cleanup
  end
end

TestPhrase = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::PhraseToHash
end

TestTranslation = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::TranslationToHash
end
