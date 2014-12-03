# encoding: UTF-8

module Rosette
  module Serializers

    class Serializer
      attr_reader :stream, :locale, :encoding

      class << self
        def from_stream(stream)
          new(stream)
        end

        def open(file)
          new(File.open(file))
        end

        def default_extension
          raise NotImplementedError, 'expected to be implemented in child classes'
        end
      end

      def initialize(stream, locale, encoding = Encoding::UTF_8)
        @stream = stream
        @locale = locale
        @encoding = encoding
      end

      def write_key_value(trans)
        raise NotImplementedError, 'expected to be implemented in child classes'
      end

      def flush
        stream.flush
      end
    end

  end
end
