# encoding: UTF-8

module Rosette
  module Core

    class ExtractorId < Resolver
      class << self

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
