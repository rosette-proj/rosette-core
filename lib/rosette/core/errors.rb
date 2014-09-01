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

      def to_s
        "#{message} (#{language})"
      end
    end

    class ExtractionSyntaxError < StandardError
      attr_reader :message, :original_exception, :language, :file, :commit_id

      def initialize(msg, original_exception, language, file, commit_id)
        super(msg)
        @message = msg
        @original_exception = original_exception
        @language = language
        @file = file
        @commit_id = commit_id
      end

      def to_s
        "#{message} (#{language}) in #{file} at #{commit_id}"
      end
    end

  end
end
