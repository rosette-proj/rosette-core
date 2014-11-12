# encoding: UTF-8

module Rosette
  module Core
    module Commands

      class FetchCommand < GitCommand
        include WithRepoName

        def execute
          get_repo(repo_name).repo.fetch
        end
      end

    end
  end
end
