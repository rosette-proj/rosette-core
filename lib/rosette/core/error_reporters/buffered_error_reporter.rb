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
      # @param [Hash] options A hash of options to record with the error.
      # @return [void]
      def report_error(error, options = {})
        errors << { error: error, options: options }
      end

      # Add an error object to the list of collected warnings.
      #
      # @param [Exception] error The error object to add.
      # @param [Hash] options A hash of options to record with the error.
      # @return [void]
      def report_warning(error, options = {})
        warnings << { error: error, options: options }
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
      # @yield [error, options] each consecutive error and options hash.
      # @yieldparam warning [Exception] the error
      # @yieldparam options [Hash] the hash of options associated with +error+
      # @return [nil, Enumerator] +nil+ if no block is given, an +Enumerator+
      #   otherwise.
      def each_error(&block)
        if block_given?
          errors.each do |error_hash|
            yield error_hash[:error], error_hash[:options]
          end
        else
          to_enum(__method__)
        end
      end

      # Iterates over and yields each warning. If no block is given, returns
      # an +Enumerator+.
      #
      # @yield [warning, options] each consecutive warning and options hash.
      # @yieldparam warning [Exception] the warning
      # @yieldparam options [Hash] the hash of options associated with +warning+
      # @return [nil, Enumerator] +nil+ if no block is given, an +Enumerator+
      def each_warning(&block)
        if block_given?
          warnings.each do |warning_hash|
            yield warning_hash[:error], warning_hash[:options]
          end
        else
          to_enum(__method__)
        end
      end
    end

  end
end
