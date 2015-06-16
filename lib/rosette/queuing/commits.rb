# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      autoload :CommitConductor, 'rosette/queuing/commits/commit_conductor'
      autoload :CommitJob,       'rosette/queuing/commits/commit_job'

      autoload :Stage,           'rosette/queuing/commits/stage'
      autoload :FetchStage,      'rosette/queuing/commits/fetch_stage'
      autoload :ExtractStage,    'rosette/queuing/commits/extract_stage'
      autoload :PushStage,       'rosette/queuing/commits/push_stage'
      autoload :FinalizeStage,   'rosette/queuing/commits/finalize_stage'

    end
  end
end
