# encoding: UTF-8

module Rosette
  module Core

    # Error reporter interface.
    class ErrorReporter
      # Report an error.
      #
      # @raise [NotImplementedError]
      def report_error(error, options = {})
        raise NotImplementedError, 'Please use a derived class.'
      end

      # Report a warning.
      #
      # @raise [NotImplementedError]
      def report_warning(error, options = {})
        raise NotImplementedError, 'Please use a derived class.'
      end

      # Catch errors raised by the block and report them.
      def with_error_reporting
        yield
      rescue Exception => e
        report_error(e)
      end
    end

  end
end
