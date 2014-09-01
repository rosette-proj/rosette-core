# encoding: UTF-8

module Rosette
  module Core

    module PhraseToHash
      def to_h
        { key: key, meta_key: meta_key, file: file, commit_id: commit_id }
      end
    end

  end
end
