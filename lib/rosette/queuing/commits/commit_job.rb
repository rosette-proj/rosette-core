# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Encapsulates processing a commit at a specific stage in the process.
      #
      # @!attribute [r] repo_name
      #   @return [String] the name of the repo the commit belongs to.
      # @!attribute [r] commit_id
      #   @return [String] the commit id to process.
      # @!attribute [r] status
      #   @return [String] the current status of the commit (mostly for display
      #     and tracking purposes).
      class CommitJob < Job
        attr_reader :repo_name, :commit_id, :status

        set_queue 'commits'

        # Creates a new [CommitJob] object from a [Stage].
        #
        # @param [Stage] stage The stage to get parameters from.
        # @return [CommitJob]
        def self.from_stage(stage)
          new(
            stage.repo_config.name,
            stage.commit_log.commit_id,
            stage.commit_log.status
          )
        end

        # Creates a new instance of [CommitJob].
        #
        # @param [String] repo_name The name of the repo the commit belongs to.
        # @param [String] commit_id The commit id to process.
        # @param [String] status The current status of the commit (mostly for
        #   display and tracking purposes).
        # @return [CommitJob]
        def initialize(repo_name, commit_id, status = nil)
          @repo_name = repo_name
          @commit_id = commit_id
          @status = status
        end

        # Converts this job into a list of arguments that should be able to be
        # easily serialized for placement into a queue. These should be the
        # same values the constructor accepts, since +CommitJob+s will be
        # re-instantiated with these arguments when executed.
        #
        # @return [Array]
        def to_args
          [repo_name, commit_id, status]
        end

        # Fetches the commit log, instantiates a new [CommitConductor] and
        # advances the commit to the next stage. If the commit log does not
        # exist in the database, one will be created.
        #
        # @param [Configurator] rosette_config
        # @param [Logger] logger
        # @return [void]
        def work(rosette_config, logger)
          commit_log = find_or_create_commit_log(rosette_config)
          conductor = CommitConductor.new(rosette_config, repo_name, logger)
          conductor.advance(commit_log)
        end

        protected

        def find_or_create_commit_log(rosette_config)
          # god this is cumbersome... the datastore could really use a refactor
          if commit_log = lookup_commit_log(rosette_config)
            commit_log
          else
            rosette_config.datastore.add_or_update_commit_log(
              repo_name, commit_id, nil, Rosette::DataStores::PhraseStatus::NOT_SEEN
            )

            lookup_commit_log(rosette_config)
          end
        end

        def lookup_commit_log(rosette_config)
          rosette_config.datastore.lookup_commit_log(
            repo_name, commit_id
          )
        end
      end

    end
  end
end
