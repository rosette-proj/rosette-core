# encoding: UTF-8

module Rosette
  module Core

    # Stores warnings errors in an internal buffer.
    #
    # @!attribute [r] errors
    #   @return [Array<Exception>] the list of collected errors.
    # @!attribute [r] warnings
    #   @return [Array<Exception>] the list of collected warnings.
    class BufferedErrorReporter < ErrorReporter
      attr_reader :errors, :warnings

      def initialize
        reset
      end

      # Add an error object to the list of collected errors.
      #
      # @param [Exception] error The error object to add.
      # @return [void]
      def report_error(error)
        errors << error
      end

      # Add an error object to the list of collected warnings.
      #
      # @param [Exception] error The error object to add.
      # @return [void]
      def report_warning(error)
        warnings << error
      end

      # Clears all errors and warnings
      #
      # @return [void]
      def reset
        @errors = []
        @warnings = []
      end

      # Returns true if one or more errors has been added, false otherwise.
      #
      # @return [Boolean] Whether or not one or more errors have been added.
      def errors_found?
        errors.size > 0
      end

      # Returns true if one or more warnings has been added, false otherwise.
      #
      # @return [Boolean] Whether or not one or more errors have been added.
      def warnings_found?
        warnings.size > 0
      end

      # Iterates over and yields each error. If no block is given, returns
      # an +Enumerator+.
      #
      # @return [nil, Enumerator] +nil+ if no block is given, an +Enumerator+
      #   otherwise.
      def each_error(&block)
        if block_given?
          errors.each(&block)
        else
          errors.each
        end
      end

      # Iterates over and yields each warning. If no block is given, returns
      # an +Enumerator+.
      #
      # @return [nil, Enumerator] +nil+ if no block is given, an +Enumerator+
      #   otherwise.
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
