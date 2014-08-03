# encoding: UTF-8

module Rosette
  module Core

    class ProgressReporter
      DEFAULT_STEP = 1

      attr_reader :step, :last_count, :on_progress_proc, :on_complete_proc

      protected :on_progress_proc
      protected :on_complete_proc

      def initialize
        @step = DEFAULT_STEP
        reset
      end

      def on_progress(&block)
        @on_progress_proc = block
        self
      end

      def on_complete(&block)
        @on_complete_proc = block
        self
      end

      def set_step(step)
        @step = step
        self
      end

      def report_progress(count, total)
        if on_progress_proc
          notify_of_progress(count, total) if count % step == 0
        end

        @last_count = count
      end

      def report_complete
        if on_complete_proc
          notify_of_completion
        end
      end

      def reset
        @last_count = 0
      end

      protected

      # this won't get called if on_progress_proc is nil
      def notify_of_progress(count, total)
        on_progress_proc.call(
          count, total, percentage(count, total)
        )
      end

      # this won't get called if on_complete_proc is nil
      def notify_of_completion
        on_complete_proc.call
      end

      private

      def percentage(count, total, precision = 0)
        ((count.to_f / total.to_f) * 100).round(precision)
      rescue => e
        binding.pry
      end
    end

  end
end
