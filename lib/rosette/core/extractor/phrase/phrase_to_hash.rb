# encoding: UTF-8

module Rosette
  module Core

    module PhraseToHash
      def to_h
        {
          key: key,
          meta_key: meta_key,
          file: file,
          commit_id: commit_id,
          author_name: author_name,
          author_email: author_email,
          commit_datetime: commit_datetime
        }
      end
    end

  end
end
