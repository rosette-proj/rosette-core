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
              transition [PENDING, PULLING] => PULLING
              transition TRANSLATED => TRANSLATED
              transition PULLED => PULLED
            end

            # called by completer when phrases are fully translated
            event :translate do
              transition [PULLING, PULLED] => PULLED
              transition TRANSLATED => TRANSLATED
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
