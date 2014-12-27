# encoding: UTF-8

module Rosette
  module Core

    # An error reporter that does nothing.
    class NilErrorReporter < ErrorReporter
      # Get a reference to the only instance of +NilErrorReporter+.
      #
      # @return [NilErrorReporter] the only instance of +NilErrorReporter+.
      def self.instance
        @instance ||= new
      end

      # Does nothing.
      # @return [nil]
      def report_error(error); end

      # Does nothing.
      # @return [nil]
      def report_warning(error); end
    end

  end
end
