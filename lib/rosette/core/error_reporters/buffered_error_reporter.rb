# encoding: UTF-8

module Rosette
  module Core

    class BufferedErrorReporter
      attr_reader :errors, :warnings

      def initialize
        reset
      end

      def report_error(error)
        errors << error
      end

      def report_warning(error)
        warnings << error
      end

      def reset
        @errors = []
        @warnings = []
      end

      def errors_found?
        errors.size > 0
      end

      def warnings_found?
        warnings.size > 0
      end

      def each_error(&block)
        if block_given?
          errors.each(&block)
        else
          errors.each
        end
      end

      def each_warning(&block)
        if block_given?
          warnings.each(&block)
        else
          warnings.each
        end
      end
    end

  end
end
