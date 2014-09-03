# encoding: UTF-8

module Rosette
  module Core

    class BufferedErrorReporter
      attr_reader :errors

      def initialize
        reset
      end

      def report_error(error)
        errors << error
      end

      def reset
        @errors = []
      end

      def errors_found?
        errors.size > 0
      end

      def each_error(&block)
        if block_given?
          errors.each(&block)
        else
          errors.each
        end
      end
    end

  end
end
