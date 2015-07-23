# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Provides a set of constants that specify how to determine the set of
      # phrases to push to a translation management system (TMS).
      class PhraseStorageGranularity
        # Push only the phrases that were added or changed in single commits.
        COMMIT = 'COMMIT'

        # Push all the phrases contained by each git branch, regardless of the
        # order of commits.
        BRANCH = 'BRANCH'
      end

    end
  end
end
