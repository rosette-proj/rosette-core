# encoding: UTF-8

module Rosette
  module Core

    # Turns a {Phrase} into a hash. Must be mixed into a {Phrase}-like class.
    #
    # @example
    #   p = Phrase.new
    #   p.key = 'foo'
    #   p.meta_key = 'bar'
    #   p.file = '/path/to/file.yml'
    #
    #   p.to_h  # => { key: 'foo', meta_key: 'bar', file: '/path/to/file.yml' ... }
    module PhraseToHash
      # Converts the attributes of a {Phrase} into a hash of attributes.
      #
      # @return [Hash] a hash of phrase attributes.
      def to_h
        {
          key: key,
          meta_key: meta_key,
          file: file,
          commit_id: commit_id,
          author_name: author_name,
          author_email: author_email,
          line_number: line_number
        }
      end
    end

  end
end
