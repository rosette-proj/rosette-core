# encoding: UTF-8

module Rosette
  module Core

    # Logic for handling preprocessor ids. Preprocessor ids are strings that
    # refer to a particular preprocessor class. For example, the id
    # 'normalization' refers to
    # +Rosette::Preprocessors::NormalizationPreprocessor+.
    #
    # @example
    #   PreprocessorId.resolve('normalization')
    #   # => Rosette::Preprocessors::NormalizationPreprocessor
    class PreprocessorId < Resolver
      class << self

        # Parses and identifies the class constant for the given preprocessor id.
        #
        # @param [Class, String] id When given a class, returns the class. When
        #   given a string, parses and identifies the corresponding class
        #   constant in +namespace+.
        # @param [Class] namespace The namespace to look in.
        # @return [Class] The identified class constant.
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
