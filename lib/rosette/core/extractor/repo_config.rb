# encoding: UTF-8

module Rosette
  module Core

    class RepoConfig
      include Integrations::Integratable

      attr_reader :name, :repo, :locales, :hooks
      attr_reader :extractor_configs, :serializer_configs

      def initialize(name)
        @name = name
        @extractor_configs = []
        @serializer_configs = []
        @locales = []

        @hooks = Hash.new do |h, key|
          h[key] = Hash.new do |h2, key2|
            h2[key2] = []
          end
        end
      end

      def set_path(path)
        @repo = Repo.from_path(path)
      end

      def path
        repo.path if repo
      end

      def add_extractor(extractor_id)
        klass = ExtractorId.resolve(extractor_id)
        config = ExtractorConfig.new(klass)
        yield config if block_given?
        extractor_configs << config
      end

      def add_serializer(name, options = {})
        serializer_id = options[:format]
        klass = SerializerId.resolve(serializer_id)
        config = SerializerConfig.new(name, klass, serializer_id)
        yield config if block_given?
        serializer_configs << config
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
        hooks[:after][action] << block
      end

      def get_extractor_configs(path)
        extractor_configs.select do |config|
          config.matches?(path)
        end
      end

      def get_serializer_config(name_or_id)
        found = serializer_configs.find do |config|
          config.name == name_or_id
        end

        found || serializer_configs.find do |config|
          config.serializer_id == name_or_id
        end
      end

      def get_locale(code, format = Locale::DEFAULT_FORMAT)
        locale_to_find = Locale.parse(code, format)
        locales.find { |locale| locale == locale_to_find }
      end
    end

  end
end
