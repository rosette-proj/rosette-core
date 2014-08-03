# encoding: UTF-8

module Rosette
  module Core

    class StagedProgressReporter < ProgressReporter
      DEFAULT_STAGE = :start

      attr_reader :stage, :on_stage_changed_proc, :on_stage_finished_proc
      protected :on_stage_changed_proc
      protected :on_stage_finished_proc

      def initialize
        super
        @stage = DEFAULT_STAGE
      end

      def set_stage(stage)
        @stage = stage
        self
      end

      def change_stage(new_stage)
        if on_stage_changed_proc
          notify_of_stage_change(new_stage, stage)
        end

        @stage = new_stage
      end

      def report_stage_finished(count, total)
        if on_stage_finished_proc
          notify_of_stage_finish(count, total)
        end

        @last_count = count
      end

      def on_stage_changed(&block)
        @on_stage_changed_proc = block
        self
      end

      def on_stage_finished(&block)
        @on_stage_finished_proc = block
        self
      end

      protected

      # this won't get called if on_progress_proc is nil
      def notify_of_progress(count, total)
        on_progress_proc.call(
          count, total, percentage(count, total), stage
        )
      end

      # this won't get called if on_finished_proc is nil
      def notify_of_stage_finish(count, total)
        on_stage_finished_proc.call(
          count, total, percentage(count, total), stage
        )
      end

      # this won't get called if on_stage_changed_proc is nil
      def notify_of_stage_change(new_stage, old_stage)
        on_stage_changed_proc.call(new_stage, old_stage)
      end
    end

  end
end
