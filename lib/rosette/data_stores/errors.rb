# encoding: UTF-8

module Rosette
  module DataStores
    module Errors

      class AddTranslationError < StandardError; end
      class PhraseNotFoundError < StandardError; end
      class MissingParamError < StandardError; end
      class CommitLogUpdateError < StandardError; end

    end
  end
end
