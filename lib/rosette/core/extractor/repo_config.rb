# encoding: UTF-8

module Rosette
  module Core

    class RepoConfig
      attr_reader :name, :path, :repo, :extractor_configs

      def initialize(name)
        @name = name
        @extractor_configs = []
      end

      def set_path(path)
        @path = path
        @repo = Repo.from_path(path)
      end

      def add_extractor(extractor_id)
        klass = ExtractorId.resolve(extractor_id)
        extractor_configs << ExtractorConfig.new(
          klass, yield(ExtractorConfigurationFactory.create_root)
        )
      end

      def get_extractor_configs(path)
        extractor_configs.select do |config|
          config.matches?(path)
        end
      end
    end

  end
end
