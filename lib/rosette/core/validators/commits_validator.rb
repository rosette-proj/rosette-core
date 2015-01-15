# encoding: UTF-8

module Rosette
  module Core
    module Validators

      # Validates the existence of an array of commits.
      #
      # @example
      #   v = CommitsValidator.new
      #   v.valid?(['73cd130a42017d794ffa86ef0d255541d518a7b3'], 'my_repo', config)
      #   # => true
      #
      #   v.valid?(['non-existent-ref'], 'my_repo', config)
      #   # => false
      #
      #   v.messages  # => ["Unable to find commit 'non-existent-ref'."]
      class CommitsValidator < CommitValidator
        def valid?(commit_strs, repo_name, configuration)
          commit_strs.all? do |commit_str|
            super(commit_str, repo_name, configuration)
          end
        end
      end

    end
  end
end
