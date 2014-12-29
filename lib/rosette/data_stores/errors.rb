# encoding: UTF-8

module Rosette
  module DataStores

    # Errors that can be raised during data store operations.
    module Errors
      # Raised when an error occurs when adding a new translation.
      class AddTranslationError < StandardError; end

      # Raised when a phrase with the given attributes cannot be found.
      class PhraseNotFoundError < StandardError; end

      # Raised when the appropriate translation parameters aren't provided.
      class MissingParamError < StandardError; end

      # Raised when a commit log entry can't be updated.
      class CommitLogUpdateError < StandardError; end

      # Raised when one of the locale entries for a commit log can't be
      # updated.
      class CommitLogLocaleUpdateError < StandardError; end
    end

  end
end
