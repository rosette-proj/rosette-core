# encoding: UTF-8

module Rosette
  module Core

    # Prints errors.
    #
    # @!attribute [r] stream
    #   @return [#write] a stream-like object to print errors to.
    # @!attribute [r] print_stack_trace
    #   @return [Boolean] whether or not to print a stack trace along with
    #     the error message.
    class PrintingErrorReporter < ErrorReporter
      attr_reader :stream, :print_stack_trace
      alias :print_stack_trace? :print_stack_trace

      # Creates a new error reporter.
      #
      # @param [#write] stream The stream-like object to print errors to.
      # @param [Hash] options A hash of options. Can contain:
      #   * +print_stack_trace+: A boolean value indicating whether or not
      #     a stack trace should be printed alongside the error message.
      def initialize(stream, options = {})
        @stream = stream
        @print_stack_trace = options.fetch(:print_stack_trace, false)
      end

      # Print an error.
      #
      # @param [Exception] error The error to print.
      def report_error(error)
        stream.write("#{error.message}\n")

        if print_stack_trace?
          Array(error.backtrace).each do |line|
            stream.write("#{line}\n")
          end
        end
      end

      # Print a warning. Warnings are treated the same as errors.
      #
      # @param [Exception] error The error to print.
      def report_warning(error)
        report_error(error)
      end
    end

  end
end
