# encoding: UTF-8

module Rosette
  module Core

    # Raised when locale parsing fails.
    class InvalidLocaleError < StandardError; end

    # Base class for representing locales. Locales are defined as a combination
    # of language and territory. For example, the BCP-47 locale code for
    # English from the United States is "en-US". The first part, "en", stands
    # for "English", while the second part, "US", stands for "United States".
    #
    # @!attribute [r] language
    #   @return [String] the locale's language component.
    # @!attribute [r] territory
    #   @return [String] the locale's territory component.
    class Locale
      DEFAULT_FORMAT = :bcp_47

      class << self
        # Using the given format, separate the locale code into langauge and
        # territory.
        #
        # @param [String] locale_code The locale code to parse.
        # @param [Symbol] format The format of the locale.
        # @return [Locale]
        def parse(locale_code, format = DEFAULT_FORMAT)
          format_str = "#{StringUtils.camelize(format.to_s)}Locale"

          if Rosette::Core.const_defined?(format_str)
            Rosette::Core.const_get(format_str).parse(locale_code)
          else
            raise ArgumentError, "locale format '#{format}' wasn't recognized"
          end
        end
      end

      attr_reader :language, :territory

      # Creates a new locale.
      #
      # @param [String] language the locale's language component.
      # @param [nil, String] territory The locale's territory component.
      def initialize(language, territory = nil)
        @language = language
        @territory = territory
        after_initialize
      end

      # Determines if this locale is equal to another. In order for locales
      # to be equal, both the language and territory must be equal. This method
      # ignores casing.
      #
      # @param [Locale] other The locale to compare to this one.
      # @return [Boolean] true if +other+ and this locale are equivalent, false
      #   otherwise.
      def eql?(other)
        other.is_a?(self.class) &&
          downcase(other.language) == downcase(language) &&
          downcase(other.territory) == downcase(territory)
      end

      # A synonym for {#eql}.
      #
      # @param [Locale] other
      # @return [Boolean]
      def ==(other)
        eql?(other)
      end

      private

      def after_initialize; end

      def downcase(str)
        (str || '').downcase
      end
    end

    # Represents a locale in the BCP-47 format.
    class Bcp47Locale < Locale
      class << self
        # Separates the locale code into langauge and territory components.
        #
        # @param [String] locale_code The locale code to parse.
        # @return [Locale]
        def parse(locale_code)
          if valid?(locale_code)
            new(*locale_code.split(/[-_]/))
          else
            raise InvalidLocaleError, "'#{locale_code}' is not a valid BCP-47 locale"
          end
        end

        # Determines if the given locale code is a valid BCP-47 locale.
        #
        # @param [String] locale_code The locale code to validate.
        def valid?(locale_code)
          !!(locale_code =~ /\A[a-zA-Z]{2,4}(?:[-_][a-zA-Z0-9]{2,5})?\z/)
        end
      end

      # Constructs a string locale code from the language and territory components.
      #
      # @return [String] the language and territory separated by a dash.
      def code
        territory ? language + "-#{territory}" : language
      end
    end

  end
end
