# encoding: UTF-8

require 'rspec'
require 'rosette/core'
require 'repo-fixture'
require 'fileutils'
require 'pry-nav'

require 'spec/helpers/test_extractor'

RSpec.configure do |config|
  config.mock_with :rr

  # build all repo fixtures
  fixture_path = File.join(File.expand_path('./', File.dirname(__FILE__)), 'fixtures/repos')
  bin_dir = File.join(fixture_path, 'bin')
  puts "Removing old fixtures at #{fixture_path}"
  FileUtils.rm_rf(bin_dir)
  FileUtils.mkdir_p(bin_dir)

  Dir.glob(File.join(fixture_path, 'lib/*.rb')).each do |fixture_script|
    STDOUT.write("Building repo fixture in #{fixture_script} ... ")
    load fixture_script
    puts 'done.'
  end
end

TestPhrase = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::PhraseToHash
end

TestTranslation = Struct.new(:key, :meta_key, :file, :commit_id) do
  include Rosette::Core::TranslationToHash
end
