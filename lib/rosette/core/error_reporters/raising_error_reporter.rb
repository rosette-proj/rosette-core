# encoding: UTF-8

module Rosette
  module Core

    # Raises errors instead of printing or logging them.
    class RaisingErrorReporter < ErrorReporter
      # Raises an error.
      #
      # @param [Exception] error The error to raise.
      # @param [Hash] options A hash of associated options.
      # @return [void]
      def report_error(error, options = {})
        puts options.inspect
        raise error
      end

      # Does nothing.
      #
      # @param [Exception] error An error, but nothing is done with it.
      # @param [Hash] options A hash of associated options.
      # @return [void]
      def report_warning(error, options = {})
      end
    end

  end
end
