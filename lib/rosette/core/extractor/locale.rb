# encoding: UTF-8

module Rosette
  module Core

    class InvalidLocaleError < StandardError; end

    class Locale
      DEFAULT_FORMAT = :bcp_47

      class << self
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

      def initialize(language, territory = nil)
        @language = language
        @territory = territory
        after_initialize
      end

      private

      def after_initialize; end
    end

    class Bcp47Locale < Locale
      class << self
        def parse(locale_code)
          if valid?(locale_code)
            new(*locale_code.split(/[-_]/))
          else
            raise InvalidLocaleError, "'#{locale_code}' is not a valid BCP-47 locale"
          end
        end

        # @TODO this probably isn't very correct
        def valid?(locale_code)
          !!(locale_code =~ /\A[a-zA-Z]{2,4}(?:[-_][a-zA-Z0-9]{2,5})?\z/)
        end
      end

      def code
        territory ? language + "-#{territory}" : language
      end

      def eql?(other)
        other.is_a?(self.class) &&
          downcase(other.language) == downcase(language) &&
          downcase(other.territory) == downcase(territory)
      end

      def ==(other)
        eql?(other)
      end

      def downcase(str)
        (str || '').downcase
      end
    end

  end
end
