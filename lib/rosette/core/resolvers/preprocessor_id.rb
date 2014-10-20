# encoding: UTF-8

module Rosette
  module Core

    class PreprocessorId < Resolver
      class << self

        def resolve(preprocessor_id, namespace = Rosette::Preprocessors)
          super
        end

        private

        def suffix
          'Preprocessor'
        end

      end
    end

  end
end
