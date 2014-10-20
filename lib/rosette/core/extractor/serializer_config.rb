# encoding: UTF-8

module Rosette
  module Core

    class SerializerConfig
      attr_reader :name, :klass, :serializer_id, :preprocessors

      def initialize(name, klass, serializer_id)
        @name = name
        @klass = klass
        @serializer_id = serializer_id
        @preprocessors = []
      end

      def add_preprocessor(preprocessor_id, &block)
        klass = PreprocessorId.resolve(preprocessor_id)
        preprocessors << klass.configure(&block)
      end
    end

  end
end
