# encoding: UTF-8

require 'rspec'
require 'rosette/core'
require 'repo-fixture'
require 'fileutils'
require 'pry-nav'

require 'spec/helpers/test_extractor'

RSpec.configure do |config|
  config.mock_with :rr

  before(:all) do
    fixture_path = File.join(File.expand_path('./', File.dirname(__FILE__)), 'spec/fixtures/repos')
    FileUtils.rm_rf(File.join(fixture_path, 'bin/*'))
    Dir.glob(File.join(fixture_path, 'lib/*.rb')).each do |fixture_script|
      load fixture_script
    end
  end
end

TestPhrase = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::PhraseToHash
end

TestTranslation = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::TranslationToHash
end
