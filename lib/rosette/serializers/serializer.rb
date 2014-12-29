# encoding: UTF-8

module Rosette
  module Serializers

    # Base class for all Rosette's serializers.
    #
    # @!attribute [r] stream
    #   @return [#write, #flush] an IO-style object to write the serialized
    #     phrases or translations to.
    # @!attribute [r] locale
    #   @return [String] the locale to expect the phrases or tranlsations to
    #     be written in.
    # @!attribute [r] encoding
    #   @return [String, Encoding] the encoding to use when writing the phrases
    #     or translations to +stream+.
    class Serializer
      attr_reader :stream, :locale, :encoding

      class << self
        # Creates a new serializer around the given stream.
        #
        # @param [#write, #flush] stream The stream object to write serialized
        #   phrases and translations to.
        # @return [Serializer]
        def from_stream(stream)
          new(stream)
        end

        # Creates a new serializer around the given file. Opens the file and
        # instantiates a new serializer with the handle.
        #
        # @param [String] file The file.
        def open(file)
          new(File.open(file))
        end

        # Returns the default file extension for the file type this serializer
        # generates. For example, if this is the yaml/rails serializer, the
        # default extension would be '.yml'.
        #
        # @raise [NotImplementedError]
        def default_extension
          raise NotImplementedError,
            'expected to be implemented in derived classes'
        end
      end

      # Creates a new serializer.
      #
      # @param [#write, #flush] stream The stream to write serialized phrases
      #   or translations to.
      # @param [String] locale The locale of the translations to write to
      #   +stream+.
      # @param [String, Encoding] encoding The encoding to use when writing the
      #   phrases or translations to +stream+.
      def initialize(stream, locale, encoding = Encoding::UTF_8)
        @stream = stream
        @locale = locale
        @encoding = encoding
      end

      # Serializes and writes a key/value pair to the stream. The key is often
      # a phrase key or meta key, and the value is often a foreign-language
      # translation.
      #
      # @param [String] key The phrase key or meta key.
      # @param [String] value
      # @return [void]
      # @raise [NotImplementedError]
      def write_key_value(key, value)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Writes raw text to +stream+ without serializing it first.
      #
      # @param [String] text The raw text to write.
      # @return [void]
      # @raise [NotImplementedError]
      def write_raw(text)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Flushes any buffered text from +stream+ (i.e. forces buffered text
      # to be written immediately).
      #
      # @return [void]
      def flush
        stream.flush
      end
    end

  end
end
