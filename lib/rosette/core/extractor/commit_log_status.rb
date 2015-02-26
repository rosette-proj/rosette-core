# encoding: UTF-8

require 'state_machine'

module Rosette
  module Core

    # Provides a state machine for transitioning between the possible states of
    # a commit log.
    module CommitLogStatus
      include Rosette::DataStores::PhraseStatus

      def self.included(base)
        base.class_eval do
          class_initialize = instance_method(:initialize)

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

          state_machine_initialize = instance_method(:initialize)

          # state_machine overrides base's initializer, which can be bad.
          # For example, if base's initializer sets up the initial state of
          # the state machine (eg. @state = 'foo'), the fact that the state
          # machine's initializer gets called first means @state doesn't get
          # set and therefore isn't available to the state machine (the
          # initial state will be nil). By grabbing references to both
          # initialize methods, we can re-define initialize to call them in
          # the right order.
          define_method(:initialize) do |*args, &block|
            class_initialize.bind(self).call(*args, &block)
            state_machine_initialize.bind(self).call(*args, &block)
          end
        end
      end
    end

  end
end
