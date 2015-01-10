# encoding: UTF-8

module Rosette
  module Core

    # Raises errors instead of printing or logging them.
    class RaisingErrorReporter < ErrorReporter
      # Raises an error.
      #
      # @param [Exception] error The error to raise.
      # @return [void]
      def report_error(error)
        raise error
      end

      # Does nothing.
      #
      # @param [Exception] error An error, but nothing is done with it.
      # @return [void]
      def report_warning(error)
      end
    end

  end
end
