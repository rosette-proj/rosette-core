# encoding: UTF-8

module Rosette
  module Core

    # Configuration for a serializer. Should generally be configured using
    # an instance of {RepoConfig}.
    #
    # @see RepoConfig
    #
    # @example
    #   RepoConfig.new('my_repo')
    #     .add_serializer('rails', 'yaml/rails') do |ser|
    #       ser.add_preprocessor('normalization') do |pre|
    #         pre.set_normalization_form(:nfc)
    #       end
    #     end
    #
    # @!attribute [r] name
    #   @return [String] the semantic name of this serializer.
    # @!attribute [r] klass
    #   @return [Class] the serializer's class.
    # @!attribute [r] serializer_id
    #   @return [String] the id of the serializer.
    # @!attribute [r] preprocessors
    #   @return [Array] a list of preprocessor configurations.
    class SerializerConfig
      attr_reader :name, :klass, :serializer_id, :preprocessors

      # Creates a new serializer config.
      #
      # @param [String] name The semantic name of this serializer.
      # @param [Class] klass The serializer's class.
      # @param [String] serializer_id The id of the serializer.
      def initialize(name, klass, serializer_id)
        @name = name
        @klass = klass
        @serializer_id = serializer_id
        @preprocessors = []
      end

      # Adds a pre-processor to this serializer config. The given block
      # will be passed to the pre-processor's configurator, which will
      # in turn yield the configurator to you.
      #
      # @param [String] preprocessor_id The id of the preprocessor to add.
      def add_preprocessor(preprocessor_id, &block)
        klass = PreprocessorId.resolve(preprocessor_id)
        preprocessors << klass.configure(&block)
      end
    end

  end
end
