# encoding: UTF-8

require 'java'

module Rosette
  module Core
    autoload :StringUtils,               'rosette/core/string_utils'

    autoload :Repo,                      'rosette/core/git/repo'
    autoload :DiffFinder,                'rosette/core/git/diff_finder'

    autoload :Snapshot,                  'rosette/core/snapshots/snapshot'
    autoload :SnapshotFactory,           'rosette/core/snapshots/snapshot_factory'
    autoload :FileTypeFilter,            'rosette/core/snapshots/file_type_filter'

    autoload :ProgressReporter,          'rosette/core/progress_reporters/progress_reporter'
    autoload :NilProgressReporter,       'rosette/core/progress_reporters/nil_progress_reporter'
    autoload :StagedProgressReporter,    'rosette/core/progress_reporters/staged_progress_reporter'
    autoload :NilStagedProgressReporter, 'rosette/core/progress_reporters/nil_staged_progress_reporter'

    autoload :Extractor,                  'rosette/core/extractor/extractor'
    autoload :Phrase,                     'rosette/core/extractor/phrase'
    autoload :ExtractorConfig,            'rosette/core/extractor/extractor_config'
    autoload :RepoConfig,                 'rosette/core/extractor/repo_config'
    autoload :ExtractorId,                'rosette/core/extractor/extractor_id'
  end
end
