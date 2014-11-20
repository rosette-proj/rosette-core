# encoding: UTF-8

# SimpleCov code adapted from:
# http://www.dixis.com/?p=713
require 'simplecov'

SimpleCov.start

all_files = Dir['./lib/**/*.rb']
base_result = {}

all_files.each do |file|
  absolute = File::expand_path(file)
  lines = File.readlines(absolute, :encoding => 'UTF-8')

  base_result[absolute] = lines.map do |l|
    l.strip!
    l.empty? || l =~ /^end$/ || l[0] == '#' ? nil : 0
  end
end

SimpleCov.at_exit do
  coverage_result = Coverage.result
  covered_files = coverage_result.keys

  covered_files.each do |covered_file|
    base_result.delete(covered_file)
  end

  merged = SimpleCov::Result.new(coverage_result)
    .original_result
    .merge_resultset(base_result)

  result = SimpleCov::Result.new(merged)
  result.format!
end


require 'jbundler'
require 'rspec'
require 'rosette/core'
require 'rosette/serializers'
require 'rosette/integrations'
require 'rosette/preprocessors'
require 'rosette/data_stores'
require 'rosette/data_stores/in_memory_data_store'
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
        ext.set_conditions do |conditions|
          conditions.match_file_extension('.txt')
        end
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
