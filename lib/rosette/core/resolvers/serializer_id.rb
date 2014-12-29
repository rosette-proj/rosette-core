# encoding: UTF-8

module Rosette
  module Core

    # Logic for handling serializer ids. Serializer ids are strings that refer to
    # a particular serializer class. For example, the id 'yaml/rails' refers to
    # +Rosette::Serializers::YamlSerializer::RailsSerializer+.
    #
    # @example
    #   SerializerId.resolve('yaml/rails')
    #   # => Rosette::Serializers::YamlSerializer::RailsSerializer
    class SerializerId < Resolver
      class << self

        # Parses and identifies the class constant for the given serializer id.
        #
        # @param [Class, String] serializer_id When given a class, returns the
        #   class. When given a string, parses and identifies the corresponding
        #   class constant in +namespace+.
        # @param [Class] namespace The namespace to look in.
        # @return [Class] The identified class constant.
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
