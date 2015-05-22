# encoding: UTF-8

module Rosette
  module Core

    # Represents a commit log. Commit logs track the status of individual
    # commits, what time the commit occurred, and how many phrases it contains.
    #
    # @!attribute [rw] repo_name
    #   @return [String] the name of the repo the commit was found in.
    # @!attribute [rw] commit_id
    #   @return [String] the git commit id.
    # @!attribute [rw] phrase_count
    #   @return [Fixnum] the number of phrases found in this commit.
    # @!attribute [rw] status
    #   @return [String] the [PhraseStatus] of this commit.
    # @!attribute [rw] commit_datetime
    #   @return [DateTime] the time this commit was made.
    class CommitLog
      def initialize(repo_name, commit_id, phrase_count = nil, status = nil, commit_datetime = nil)
        @repo_name = repo_name
        @commit_id = commit_id
        @phrase_count = phrase_count
        @status = status
        @commit_datetime = commit_datetime
      end
    end

  end
end
