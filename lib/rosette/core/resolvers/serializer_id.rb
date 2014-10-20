# encoding: UTF-8

module Rosette
  module Core

    class SerializerId < Resolver
      class << self

        def resolve(serializer_id, namespace = Rosette::Serializers)
          super
        end

        private

        def suffix
          'Serializer'
        end

      end
    end

  end
end
