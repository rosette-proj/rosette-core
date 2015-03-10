# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe RepoConfig do
  let(:config) { RepoConfig.new('repo-name') }

  describe '#set_path' do
    it 'sets the repo path and instantiates a repo object inside the config' do
      repo = TmpRepo.new
      config.set_path(repo.working_dir.join('.git').to_s)
      expect(config.repo).to be_a(Repo)
      expect(config.repo.path).to eq(repo.working_dir.to_s)
      expect(config.path).to eq(repo.working_dir.to_s)
      repo.unlink
    end
  end

  describe '#add_extractor' do
    it 'creates an extractor config, yields it, and adds it to the list of extractor configs' do
      expect(config.extractor_configs.size).to eq(0)

      config.add_extractor('test/test') do |extractor_config|
        expect(extractor_config).to be_a(ExtractorConfig)
      end

      expect(config.extractor_configs.size).to eq(1)

      config.extractor_configs.first.tap do |config|
        expect(config.extractor).to be_a(Rosette::Extractors::Test::TestExtractor)
      end
    end
  end

  describe '#add_serializer' do
    it 'creates a serializer config and adds it to the list of serializer configs' do
      expect(config.serializer_configs.size).to eq(0)
      config.add_serializer('my_serializer', format: 'test/test')
      expect(config.serializer_configs.size).to eq(1)

      config.serializer_configs.first.tap do |serializer_config|
        expect(serializer_config.klass).to eq(Rosette::Serializers::Test::TestSerializer)
        expect(serializer_config.serializer_id).to eq('test/test')
      end
    end
  end

  describe '#add_locale' do
    it 'parses the locale and adds it to the list of locales' do
      expect(config.locales.size).to eq(0)
      config.add_locale('es-MX')
      expect(config.locales.size).to eq(1)

      config.locales.first.tap do |locale|
        expect(locale.language).to eq('es')
        expect(locale.territory).to eq('MX')
      end
    end
  end

  describe '#add_locales' do
    it 'parses all the locales and adds them to the list of locales' do
      expect(config.locales.size).to eq(0)
      config.add_locales(['es-MX', 'fr-CA'])
      expect(config.locales.size).to eq(2)

      config.locales.first.tap do |locale|
        expect(locale.language).to eq('es')
        expect(locale.territory).to eq('MX')
      end

      config.locales.last.tap do |locale|
        expect(locale.language).to eq('fr')
        expect(locale.territory).to eq('CA')
      end
    end
  end

  describe '#get_extractor_configs' do
    before(:each) do
      config.add_extractor('test/test') do |extractor_config|
        extractor_config.set_conditions do |conditions|
          conditions.match_file_extension('.js')
        end
      end
    end

    it 'returns all the extractor configs that match the given file extension' do
      matching_configs = config.get_extractor_configs('foo/bar/baz.js')
      expect(matching_configs.size).to eq(1)

      matching_configs.first.tap do |extractor_config|
        expect(extractor_config.extractor).to(
          be_a(Rosette::Extractors::Test::TestExtractor)
        )
      end
    end

    it 'returns nil if no extractor can be found' do
      expect(config.get_extractor_configs('foo/bar/baz.rb')).to be_empty
    end
  end

  describe '#get_serializer_config' do
    it 'returns the serializer config that matches the given id' do
      config.add_serializer('my_serializer', format: 'test/test')
      expect(config.get_serializer_config('test/test')).to(
        be(config.serializer_configs.first)
      )
    end
  end

  describe '#get_locale' do
    it 'returns the locale object for the given code' do
      config.add_locales(['es-MX', 'fr-CA', 'zh-CN'])
      config.get_locale('fr-CA').tap do |locale|
        expect(locale).to be_a(Locale)
        expect(locale.language).to eq('fr')
        expect(locale.territory).to eq('CA')
      end
    end
  end

  describe '#add_translation_path_matcher' do
    it 'adds a translation path matcher' do
      config.add_translation_path_matcher
      expect(config.translation_path_matchers.size).to eq(1)
    end
  end

  describe '#get_translation_path_matcher' do
    it 'gets the translation path matcher for the given path' do
      config.add_translation_path_matcher do |tr|
        tr.set_conditions { |c| c.match_regex(/ja|de/) }
      end

      expect(config.get_translation_path_matcher('myconfig/values-ja')).to eq(
        config.translation_path_matchers.first
      )
    end
  end
end
