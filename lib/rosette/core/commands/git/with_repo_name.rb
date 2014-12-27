# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Mixin that handles configuration and validation of a repository name.
      # Meant to be mixed into the classes in {Rosette::Core::Commands}.
      #
      # @example
      #   class MyCommand < Rosette::Core::Commands::Command
      #     include WithRepoName
      #   end
      #
      #   cmd = MyCommand.new
      #     .set_repo_name('my_repo')
      #
      #   cmd.repo_name  # => "my_repo"
      #   cmd.valid?     # => true
      #
      #   cmd.set_repo_name('non_existent_repo')
      #   cmd.valid?     # => false
      #   cmd.messages   # => { repo_name: ["Unable to find repo 'non_existent_repo'."] }
      #
      # @!attribute [r] repo_name
      #   @return [String] the repository name.
      module WithRepoName
        attr_reader :repo_name

        # Set the repository name.
        #
        # @param [String] repo_name The repository name.
        # @return [self]
        def set_repo_name(repo_name)
          @repo_name = repo_name
          self
        end

        protected

        def self.included(base)
          if base.respond_to?(:validate)
            base.validate :repo_name, type: :repo
          end
        end
      end

    end
  end
end
