# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      class FakeCommitStage < Stage
        accepts *PhraseStatus.all

        def execute!
          commit_log.status = 'fake_stage_updated_me'
        end
      end

    end
  end
end
