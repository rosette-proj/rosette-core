# encoding: UTF-8

require 'aasm'
require 'forwardable'

module Rosette
  module Core

    # Provides a state machine for transitioning between the possible states of
    # a commit log.
    module CommitLogStatus
      def self.included(base)
        base.class_eval do
          extend Forwardable

          def_delegators :state_machine,
            *(CommitLogStateMachine.instance_methods - Object.instance_methods)

          def status
            state_machine.aasm.current_state.to_s
          end

          def status=(new_status)
            state_machine.aasm.current_state = new_status.to_sym
          end

          private

          def state_machine
            @state_machine ||= CommitLogStateMachine.new(@status)
          end
        end
      end
    end

    class CommitLogStateMachine
      include AASM

      # aasm requires all states to be symbols
      Rosette::DataStores::PhraseStatus.all.each do |status|
        self.const_set(status, status.to_sym)
      end

      def initialize(status)
        aasm.instance_variable_set(
          '@current_state', status ? status.to_sym : nil
        )
      end

      aasm do
        Rosette::DataStores::PhraseStatus.all.each do |status|
          state status.to_sym
        end

        attribute_name :status
        initial_state UNTRANSLATED

        # called on every push
        event :push do
          transitions from: [UNTRANSLATED, PENDING], to: PENDING
        end

        # called on every pull
        event :pull do
          transitions from: [PENDING, PULLING], to: PULLING
          transitions from: PULLED, to: TRANSLATED
        end

        # called on every complete
        event :complete do
          transitions from: PULLING, to: PULLED, if: (lambda do |options = {}|
            !!options.fetch(:fully_translated, false)
          end)
          transitions from: PULLING, to: PULLING
          transitions from: [PULLED, TRANSLATED], to: TRANSLATED
        end

        # handles the zero phrases case (commit bypasses pulling
        # state if it introduces no new/changed phrases)
        event :translate do
          transitions from: PhraseStatus.statuses, to: TRANSLATED
        end

        # called when jgit can't find the commit
        event :missing do
          transitions from: PhraseStatus.statuses, to: MISSING
        end
      end

    end
  end
end
