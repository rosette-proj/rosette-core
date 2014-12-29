# encoding: UTF-8

module Rosette
  module Core

    # Logic for handling extractor ids. Extractor ids are strings that refer to
    # a particular extractor class. For example, the id 'yaml/rails' refers to
    # +Rosette::Extractors::YamlExtractor::RailsExtractor+.
    #
    # @example
    #   ExtractorId.resolve('yaml/rails')
    #   # => Rosette::Extractors::YamlExtractor::RailsExtractor
    class ExtractorId < Resolver
      class << self

        # Parses and identifies the class constant for the given extractor id.
        #
        # @param [Class, String] extractor_id When given a class, returns the
        #   class. When given a string, parses and identifies the corresponding
        #   class constant in +namespace+.
        # @param [Class] namespace The namespace to look in.
        # @return [Class] The identified class constant.
        def resolve(extractor_id, namespace = Rosette::Extractors)
          super
        end

        private

        def suffix
          'Extractor'
        end

      end
    end

  end
end
