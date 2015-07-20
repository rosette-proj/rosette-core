# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Base class for stages of the commit processing pipeline.
      #
      # @!attribute [r] rosette_config
      #   @return [Configurator] the Rosette config to use.
      # @!attribute [r] repo_config
      #   @return [RepoConfig] the repo config to use.
      # @!attribute [r] logger
      #   @return [Logger] the logger to log messages to.
      # @!attribute [r] commit_log
      #   @return [CommitLog] the commit log to process.
      class Stage
        PhraseStatus = Rosette::DataStores::PhraseStatus

        class << self
          # Sets the +PhraseStatus+es this stage can handle.
          #
          # @param [Array<String>] statuses A splatted list of statuses.
          # @return [void]
          def accepts(*statuses)
            @_accepts_statuses = statuses
          end

          # Returns true if this stage accepts the given commit log (i.e. can
          # process it), false otherwise.
          #
          # @param [CommitLog] commit_log The commit log to check.
          # @return [Boolean]
          def accepts?(commit_log)
            @_accepts_statuses.include?(commit_log.status)
          end

          # If given a commit log that this stage accepts, returns an instance
          # of this stage class. If the stage does not accept the commit log,
          # returns +nil+.
          #
          # @param [CommitLog] commit_log The commit log to wrap.
          # @param [Configurator] rosette_config The Rosette config to pass to
          #   the stage instance.
          # @param [Logger] logger The logger to pass to the stage instance.
          # @return [Stage] an instance of this stage or +nil+.
          def for_commit_log(commit_log, rosette_config, logger)
            if accepts?(commit_log)
              repo_config = rosette_config.get_repo(commit_log.repo_name)
              new(rosette_config, repo_config, logger, commit_log)
            end
          end
        end

        attr_reader :rosette_config, :repo_config, :logger, :commit_log

        # Creates a new instance of this stage.
        #
        # @param [Configurator] rosette_config The Rosette config to use.
        # @param [RepoConfig] repo_config The repo config to use.
        # @param [Logger] logger The logger to log messages to.
        # @param [CommitLog] commit_log The commit log to process.
        # @return [Stage]
        def initialize(rosette_config, repo_config, logger, commit_log)
          @rosette_config = rosette_config
          @repo_config = repo_config
          @logger = logger
          @commit_log = commit_log
        end

        # Converts this stage to a job that can be enqueued.
        #
        # @return [CommitJob]
        def to_job
          CommitJob.from_stage(self)
        end

        protected

        def save_commit_log
          rosette_config.datastore.add_or_update_commit_log(
            commit_log.repo_name, commit_log.commit_id,
            commit_log.commit_datetime, commit_log.status,
            commit_log.phrase_count, commit_log.branch_name
          )
        end
      end

    end
  end
end
