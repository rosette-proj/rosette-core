# encoding: UTF-8

require 'repo-fixture'
require 'yaml'

module TestHelpers

  class FixturePhraseCommit
    attr_reader :phrase_map, :phrase_map_copy
    attr_reader :ref, :sha

    def initialize(ref, sha, phrase_map)
      @rev = ref
      @sha = sha
      @phrase_map = phrase_map
      reset
    end

    def reset
      @phrase_map_copy = phrase_map.each_with_object({}) do |(file, phrases), ret|
        ret[file] = phrases.dup
      end
    end

    def remove(phrase)
      phrase_map_copy[phrase.file].tap do |expected_phrases|
        expected_phrases.delete_if do |expected_phrase|
          expected_phrase == phrase.key
        end
      end
    end

    def has_more_phrases?
      phrase_map_copy.any? { |key, val| !val.empty? }
    end
  end

  Fixture = Struct.new(:config, :properties, :repo_fixture) do
    def respond_to?(method)
      super || repo_fixture.respond_to?(method)
    end

    def method_missing(method, *args, &block)
      repo_fixture.send(method, *args, &block)
    end

    def each_commit
      if block_given?
        properties[:phrases].each_pair do |ref, phrase_hash|
          sha = repo_fixture.git("rev-parse #{ref}").strip
          yield FixturePhraseCommit.new(ref, sha, phrase_hash)
        end
      else
        to_enum(__method__)
      end
    end
  end

  class Fixtures
    class << self

      def build_all
        puts "Removing old fixtures at #{fixture_path}"
        FileUtils.rm_rf(fixture_bin_path)
        FileUtils.mkdir_p(fixture_bin_path)

        Dir.glob(File.join(fixture_path, 'lib/*.rb')).each do |fixture_script|
          STDOUT.write("Building repo fixture in #{fixture_script} ... ")
          load fixture_script
          puts 'done.'
        end
      end

      def load_repo_fixture(fixture_name)
        repo_fixture = RepoFixture.load(
          File.join(fixture_bin_path, "#{fixture_name}.zip")
        )

        config = build_config(fixture_name, repo_fixture) do |config, repo|
          yield config, repo if block_given?
        end

        properties = load_properties_file(fixture_name)
        fixture = Fixture.new(config, properties, repo_fixture)
        fixture_registry << fixture
        fixture
      end

      def cleanup
        fixture_registry.each(&:unlink)
        fixture_registry.clear
      end

      private

      def load_properties_file(fixture_name)
        YAML.load_file(File.join(fixture_lib_path, "#{fixture_name}.yml"))
      end

      def build_config(fixture_name, repo_fixture)
        Rosette::Core::Configurator.new.tap do |config|
          config.add_repo(fixture_name) do |repo|
            repo.set_path(repo_fixture.working_dir.join('.git').to_s)
            yield config, repo if block_given?
          end
        end
      end

      def fixture_registry
        @fixture_registry ||= []
      end

      def fixture_path
        TestHelpers.fixture_path
      end

      def fixture_bin_path
        TestHelpers.fixture_bin_path
      end

      def fixture_lib_path
        TestHelpers.fixture_lib_path
      end

    end
  end

end
