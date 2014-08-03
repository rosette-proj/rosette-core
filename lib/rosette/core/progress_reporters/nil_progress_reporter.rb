# encoding: UTF-8

module Rosette
  module Core

    class NilProgressReporter
      def self.instance
        @instance ||= new
      end

      def on_progress(&block)
        self
      end

      def on_complete(&block)
        self
      end

      def set_step(step)
        self
      end

      def report_progress(count, total); end
      def report_complete; end
      def reset; end
    end

  end
end