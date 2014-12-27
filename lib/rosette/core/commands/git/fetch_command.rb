# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Performs a git fetch on a repository. New branches and commits will
      # be downloaded from the remote server (often called "origin") and
      # become part of the local copy.
      #
      # @example
      #   FetchCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .execute
      class FetchCommand < GitCommand
        include WithRepoName

        # Perform the fetch operation.
        # @return [Java::OrgEclipseJgitTransport::FetchResult]
        def execute
          get_repo(repo_name).repo.fetch
        end
      end

    end
  end
end
