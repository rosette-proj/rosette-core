# encoding: UTF-8

module Rosette
  module Core

    class SyntaxError < StandardError
      attr_reader :message, :original_exception, :language

      def initialize(msg, original_exception, language)
        super(msg)
        @message = msg
        @original_exception = original_exception
        @language = language
      end

      def message
        "#{message} (#{language})"
      end

      alias :to_s :message
    end

    class ExtractionSyntaxError < StandardError
      attr_reader :original_exception, :language, :file, :commit_id

      def initialize(msg, original_exception, language, file, commit_id)
        super(msg)
        @message = msg
        @original_exception = original_exception
        @language = language
        @file = file
        @commit_id = commit_id
      end

      def message
        "#{@message}: #{original_exception.message} (#{language}) in #{file} at #{commit_id}"
      end

      alias :to_s :message
    end

  end
end
