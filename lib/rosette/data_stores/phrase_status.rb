# encoding: UTF-8

module Rosette
  module DataStores

    # Contains several constants indicating the translation status of a set
    # of phrases. Generally attached to commit logs.
    module PhraseStatus
      # The commit has not even been seen yet, i.e. this is the first time
      # Rosette has ever encountered it.
      NOT_SEEN = 'NOT_SEEN'

      # The repository that contains this commit has been fetched in preparation
      # for processing it.
      FETCHED = 'FETCHED'

      # Indicates the phrases have been extracted from the commit.
      EXTRACTED = 'EXTRACTED'

      # The extracted phrases have been submitted for translation.
      PUSHED = 'PUSHED'

      # The commit has been completely processed.
      FINALIZED = 'FINALIZED'

      # Indicates that the commit no longer exists, i.e. the associated branch
      # was deleted or was force-pushed over.
      MISSING = 'MISSING'

      # Indicates one or all of the commits have not been processed.
      NOT_FOUND = 'NOT_FOUND'

      def self.all
        @all ||= [
          NOT_SEEN, FETCHED, EXTRACTED, PUSHED, FINALIZED, MISSING, NOT_FOUND
        ]
      end

      def self.statuses
        @statuses ||= [
          NOT_SEEN, FETCHED, EXTRACTED, PUSHED, FINALIZED
        ]
      end

      def self.incomplete
        @incomplete ||= [
          NOT_SEEN, FETCHED, EXTRACTED, PUSHED, NOT_FOUND
        ]
      end

      def self.index(status)
        (@status_index ||= {}).fetch(status) do
          statuses.index(status)
        end
      end
    end

  end
end
