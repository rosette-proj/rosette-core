# encoding: UTF-8

require 'logger'
require 'rosette/core/errors'

java_import java.lang.System

module Rosette
  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end

  def self.env
    @env || 'development'
  end

  def self.env=(new_env)
    @env = new_env
  end

  def self.build_config
    configuration = Rosette::Core::Configurator.new
    yield configuration
    configuration.apply_integrations(configuration)
    configuration
  end

  module Core
    DEFAULT_ENCODING = Encoding::UTF_8

    autoload :Configurator,                  'rosette/core/configurator'

    autoload :StringUtils,                   'rosette/core/string_utils'

    autoload :Repo,                          'rosette/core/git/repo'
    autoload :DiffFinder,                    'rosette/core/git/diff_finder'

    autoload :Snapshot,                      'rosette/core/snapshots/snapshot'
    autoload :SnapshotFactory,               'rosette/core/snapshots/snapshot_factory'
    autoload :CachedSnapshotFactory,         'rosette/core/snapshots/cached_snapshot_factory'
    autoload :HeadSnapshotFactory,           'rosette/core/snapshots/head_snapshot_factory'
    autoload :CachedHeadSnapshotFactory,     'rosette/core/snapshots/cached_head_snapshot_factory'
    autoload :SnapshotFilterable,            'rosette/core/snapshots/snapshot_filterable'
    autoload :FileTypeFilter,                'rosette/core/snapshots/file_type_filter'

    autoload :Extractor,                     'rosette/core/extractor/extractor'
    autoload :StaticExtractor,               'rosette/core/extractor/static_extractor'
    autoload :Phrase,                        'rosette/core/extractor/phrase'
    autoload :Translation,                   'rosette/core/extractor/translation'
    autoload :ExtractorConfig,               'rosette/core/extractor/extractor_config'
    autoload :ExtractorConfigurationFactory, 'rosette/core/extractor/extractor_config'
    autoload :RepoConfig,                    'rosette/core/extractor/repo_config'
    autoload :SerializerConfig,              'rosette/core/extractor/serializer_config'
    autoload :CommitProcessor,               'rosette/core/extractor/commit_processor'
    autoload :Locale,                        'rosette/core/extractor/locale'

    autoload :PhraseIndexPolicy,             'rosette/core/extractor/phrase/phrase_index_policy'
    autoload :PhraseToHash,                  'rosette/core/extractor/phrase/phrase_to_hash'

    autoload :TranslationToHash,             'rosette/core/extractor/translation/translation_to_hash'

    autoload :NilErrorReporter,              'rosette/core/error_reporters/nil_error_reporter'
    autoload :PrintingErrorReporter,         'rosette/core/error_reporters/printing_error_reporter'
    autoload :BufferedErrorReporter,         'rosette/core/error_reporters/buffered_error_reporter'

    autoload :Validators,                    'rosette/core/validators'

    autoload :Resolver,                      'rosette/core/resolvers/resolver'
    autoload :ExtractorId,                   'rosette/core/resolvers/extractor_id'
    autoload :IntegrationId,                 'rosette/core/resolvers/integration_id'
    autoload :SerializerId,                  'rosette/core/resolvers/serializer_id'
    autoload :PreprocessorId,                'rosette/core/resolvers/preprocessor_id'

    autoload :Commands,                      'rosette/core/commands'
  end
end
