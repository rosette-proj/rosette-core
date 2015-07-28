# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      autoload :CommitJob,                'rosette/queuing/commits/commit_job'
      autoload :CommitConductor,          'rosette/queuing/commits/commit_conductor'
      autoload :CommitsQueueConfigurator, 'rosette/queuing/commits/commits_queue_configurator'
      autoload :ExtractStage,             'rosette/queuing/commits/extract_stage'
      autoload :FetchStage,               'rosette/queuing/commits/fetch_stage'
      autoload :FinalizeStage,            'rosette/queuing/commits/finalize_stage'
      autoload :PhraseStorageGranularity, 'rosette/queuing/commits/phrase_storage_granularity'
      autoload :PushStage,                'rosette/queuing/commits/push_stage'
      autoload :Stage,                    'rosette/queuing/commits/stage'

    end
  end
end
