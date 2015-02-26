# encoding: UTF-8

require 'state_machine'

module Rosette
  module Core

    module CommitLogStatus
      include Rosette::DataStores::PhraseStatus

      def self.included(base)
        base.class_eval do
          state_machine :status, initial: UNTRANSLATED do
            # called on every push
            event :push do
              transition [UNTRANSLATED, PENDING] => PENDING
            end

            # called on every pull
            event :pull do
              transition [PENDING, PULLING] => PULLING
              transition PULLED => TRANSLATED
            end

            # called on every complete
            event :complete do
              transition PULLING => PULLED
              transition [PULLED, TRANSLATED] => TRANSLATED
            end

            # handles the zero phrases case (commit bypasses pulling
            # state if it introduces no new/changed phrases)
            event :translate do
              transition all => TRANSLATED
            end

            # called when jgit can't find the commit
            event :missing do
              transition all => MISSING
            end
          end
        end
      end
    end

  end
end
