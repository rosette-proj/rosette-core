# encoding: UTF-8

module Rosette
  module Core

    # Represents a phrase. Phrases are essentially text in some source
    # language.
    #
    # @!attribute [r] key
    #   @return [String] the phrase key.
    # @!attribute [r] meta_key
    #   @return [String] the phrase meta key.
    # @!attribute [rw] file
    #   @return [String] the file this phrase was found in.
    # @!attribute [rw] commit_id
    #   @return [String] the git commit id this phrase was found in.
    # @!attribute [rw] author_name
    #   @return [String] the name of the person who git thinks created
    #     this phrase.
    # @!attribute [rw] author_email
    #   @return [String] the email address of the person who git thinks
    #     created this phrase.
    # @!attribute [rw] line_number
    #   @return [Fixnum] the line number in +file+ were this phrase was
    #     found.
    class Phrase
      include PhraseIndexPolicy
      include PhraseToHash

      attr_reader :key, :meta_key
      attr_accessor :file, :commit_id
      attr_accessor :author_name, :author_email
      attr_accessor :line_number

      # Creates a new phrase.
      #
      # @param [String] key The phrase key.
      # @param [String] meta_key The phrase meta key.
      # @param [String] file The file this phrase was found in.
      # @param [String] commit_id The git commit id this phrase was found in.
      # @param [String] author_name The name of the person who git thinks
      #    created this phrase.
      # @param [String] author_email The email address of the person who git
      #   thinks created this phrase.
      # @param [Fixnum] line_number The line number in +file+ were this phrase
      #   was found.
      def initialize(key, meta_key = nil, file = nil, commit_id = nil, author_name = nil, author_email = nil, line_number = nil)
        @key = key
        @meta_key = meta_key
        @file = file
        @commit_id = commit_id
        @author_name = author_name
        @author_email = author_email
        @line_number = line_number
      end

      # Creates a phrase from a hash of attributes.
      #
      # @param [Hash] hash A hash of options containing +key+, +meta_key+,
      #   +file+, +commit_id+, +author_name+, +author_email+, and +line_number+.
      # @return [nil, Phrase] a phrase object created from +hash+. If +hash+
      #   is +nil+, returns +nil+.
      def self.from_h(hash)
        if hash
          new(
            hash[:key], hash[:meta_key],
            hash[:file], hash[:commit_id],
            hash[:author_name], hash[:author_email],
            hash[:line_number]
          )
        end
      end
    end

  end
end
