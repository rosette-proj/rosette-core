# encoding: UTF-8

require 'repo-fixture'
require 'yaml'

module TestHelpers

  Fixture = Struct.new(:config, :properties, :repo_fixture) do
    def respond_to?(method)
      repo_fixture.respond_to?(method)
    end

    def method_missing(method, *args, &block)
      repo_fixture.send(method, *args, &block)
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
