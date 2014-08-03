# encoding: UTF-8

module Rosette
  module Core

    class NilStagedProgressReporter < NilProgressReporter
      def on_stage_changed(&block)
        self
      end

      def on_stage_finished(&block)
      end

      def set_stage(stage)
        self
      end

      def change_stage(new_stage); end
      def report_stage_finished(count, total); end
    end

  end
end