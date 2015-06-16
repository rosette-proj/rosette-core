# encoding: UTF-8

require 'aasm'

module Rosette
  module Core

    # Provides a state machine for transitioning between the possible states of
    # a commit log.
    module CommitLogStatus
      # aasm requires all states to be symbols
      Rosette::DataStores::PhraseStatus.all.each do |status|
        self.const_set(status, status.to_sym)
      end

      def self.included(base)
        base.class_eval do
          include AASM

          aasm do
            # define states from PhraseStatus constants
            Rosette::DataStores::PhraseStatus.all.each do |status|
              state status.to_sym
            end

            attribute_name :status
            initial_state NOT_SEEN

            event :fetch do
              transitions from: NOT_SEEN, to: FETCHED
            end

            event :extract do
              transitions from: FETCHED, to: EXTRACTED
            end

            event :push do
              transitions from: [EXTRACTED, PUSHED], to: PUSHED
            end

            event :finalize do
              transitions from: [EXTRACTED, PUSHED, FINALIZED], to: FINALIZED
            end

            # called when jgit can't find the commit
            event :missing do
              transitions(
                from: Rosette::DataStores::PhraseStatus.statuses,
                to: MISSING
              )
            end
          end
        end
      end
    end
  end
end
