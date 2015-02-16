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
    end

  end
end
