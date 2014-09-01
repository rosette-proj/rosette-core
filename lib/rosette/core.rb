# encoding: UTF-8

require 'rosette/core/errors'

module Rosette
  module Core
    DEFAULT_ENCODING = Encoding::UTF_8

    autoload :Configurator,          'rosette/core/configurator'

    autoload :StringUtils,           'rosette/core/string_utils'
 
    autoload :Repo,                  'rosette/core/git/repo'
    autoload :DiffFinder,            'rosette/core/git/diff_finder'
 
    autoload :Snapshot,              'rosette/core/snapshots/snapshot'
    autoload :SnapshotFactory,       'rosette/core/snapshots/snapshot_factory'
    autoload :FileTypeFilter,        'rosette/core/snapshots/file_type_filter'

    autoload :Extractor,             'rosette/core/extractor/extractor'
    autoload :Phrase,                'rosette/core/extractor/phrase'
    autoload :ExtractorConfig,       'rosette/core/extractor/extractor_config'
    autoload :RepoConfig,            'rosette/core/extractor/repo_config'
    autoload :SerializerConfig,      'rosette/core/extractor/serializer_config'
    autoload :ExtractorId,           'rosette/core/extractor/extractor_id'
    autoload :SerializerId,          'rosette/core/extractor/serializer_id'
    autoload :CommitProcessor,       'rosette/core/extractor/commit_processor'
    autoload :Locale,                'rosette/core/extractor/locale'

    autoload :PhraseIndexPolicy,     'rosette/core/extractor/phrase/phrase_index_policy'
    autoload :PhraseToHash,          'rosette/core/extractor/phrase/phrase_to_hash'

    autoload :TranslationToHash,     'rosette/core/extractor/translation/translation_to_hash'

    autoload :NilErrorReporter,      'rosette/core/error_reporters/nil_error_reporter'
    autoload :PrintingErrorReporter, 'rosette/core/error_reporters/printing_error_reporter'
    autoload :BufferedErrorReporter, 'rosette/core/error_reporters/buffered_error_reporter'

    autoload :Validators,            'rosette/core/validators'
  end
end
