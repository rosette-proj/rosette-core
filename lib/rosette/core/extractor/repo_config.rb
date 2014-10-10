# encoding: UTF-8

module Rosette
  module Core

    class RepoConfig
      attr_reader :name, :repo, :locales, :hooks
      attr_reader :extractor_configs, :serializer_configs

      def initialize(name)
        @name = name
        @extractor_configs = []
        @serializer_configs = []
        @locales = []
        @hooks = Hash.new { |h, key| h[key] = [] }
      end

      def set_path(path)
        @repo = Repo.from_path(path)
      end

      def path
        repo.path if repo
      end

      def add_extractor(extractor_id)
        klass = ExtractorId.resolve(extractor_id)
        extractor_configs << ExtractorConfig.new(
          klass, yield(ExtractorConfigurationFactory.create_root)
        )
      end

      def add_serializer(serializer_id)
        klass = SerializerId.resolve(serializer_id)
        serializer_configs << SerializerConfig.new(klass, serializer_id)
      end

      def add_locale(locale_code, format = Locale::DEFAULT_FORMAT)
        add_locales(locale_code)
      end

      def add_locales(locale_codes, format = Locale::DEFAULT_FORMAT)
        @locales += Array(locale_codes).map do |locale_code|
          Locale.parse(locale_code, format)
        end
      end

      def after(action, &block)
        hooks[action] << block
      end

      def get_extractor_configs(path)
        extractor_configs.select do |config|
          config.matches?(path)
        end
      end

      def get_serializer_config(serializer_id)
        serializer_configs.find do |config|
          config.serializer_id == serializer_id
        end
      end

      def get_locale(code, format = Locale::DEFAULT_FORMAT)
        locale_to_find = Locale.parse(code, format)
        locales.find { |locale| locale == locale_to_find }
      end
    end

  end
end
