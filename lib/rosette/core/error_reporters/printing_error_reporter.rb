# encoding: UTF-8

module Rosette
  module Core

    class PrintingErrorReporter
      attr_reader :stream, :print_stack_trace
      alias :print_stack_trace? :print_stack_trace

      # stream must respond to the #write method
      def initialize(stream, options = {})
        @stream = stream
        @print_stack_trace = options.fetch(:print_stack_trace, false)
      end

      def report_error(error)
        stream.write("#{error.message}\n")

        if print_stack_trace?
          Array(error.backtrace).each do |line|
            stream.write("#{line}\n")
          end
        end
      end
    end

  end
end
