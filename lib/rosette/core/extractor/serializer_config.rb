# encoding: UTF-8

module Rosette
  module Core

    class SerializerConfig
      attr_reader :klass, :serializer_id

      def initialize(klass, serializer_id)
        @klass = klass
        @serializer_id = serializer_id
      end
    end

  end
end