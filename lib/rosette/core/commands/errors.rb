# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Custom errors that can be raised during command execution.
      module Errors
        # Raised whenever Rosette is asked to return information about
        # a commit that has not been processed (i.e. committed) yet.
        # Rosette knows nothing about commits it hasn't seen yet.
        class UnprocessedCommitError < StandardError; end
      end

    end
  end
end
