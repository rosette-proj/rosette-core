# encoding: UTF-8

module Rosette
  module Core

    # A utility class that encapsulates how translated a set of phrases is.
    # The class knows how to report translation percentages, etc.
    #
    # @!attribute [r] phrase_count
    #   @return [Fixnum] the total number of phrases.
    # @!attribute [r] locale_counts
    #   @return [Hash<Fixnum>] a hash of locale codes to counts. Each count
    #     represents the number of completed translations for that locale.
    class TranslationStatus
      attr_reader :phrase_count, :locale_counts

      # Creates a new instance.
      #
      # @param [Fixnum] phrase_count The total number of phrases.
      # @return [TranslationStatus]
      def initialize(phrase_count)
        @phrase_count = phrase_count
        @locale_counts = {}
      end

      # Adds a locale code and count pair. The count should be the total number
      # of completed translations in the locale.
      #
      # @param [String] locale_code
      # @param [Fixnum] count
      # @return [void]
      def add_locale_count(locale_code, count)
        locale_counts[locale_code] = count
      end

      # Returns true if the given locale is fully translated (i.e. the number of
      # translations is greater than or equal to the number of phrases).
      #
      # @param [String] locale_code
      # @return [Boolean]
      def fully_translated_in?(locale_code)
        locale_counts[locale_code] >= phrase_count
      end

      # Returns true if every locale is fully translated, false otherwise.
      #
      # @return [Boolean]
      def fully_translated?
        locale_counts.all? do |locale_code, _|
          fully_translated_in?(locale_code)
        end
      end

      # Retrieves the number of completed translations for the given locale.
      # Use this method in combination with +add_locale_count+.
      def locale_count(locale_code)
        locale_counts[locale_code]
      end

      # Retrieves a list of all the added locales.
      #
      # @return [Array<String>]
      def locales
        locale_counts.keys
      end

      # Calculates a translated percentage for the given locale.
      #
      # @param [String] locale_code
      # @param [Fixnum] precision The precision to use when rounding the
      #   percentage.
      # @return [Float] the translation percentage, rounded to +precision+
      #   decimal places.
      def percent_translated(locale_code, precision = 2)
        pct = locale_counts[locale_code] / phrase_count.to_f
        [1.0, pct.round(precision)].min
      end
    end

  end
end
