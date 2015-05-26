# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Coordinates moving a commit through a number of processing stages.
      #
      # @!attribute [r] rosette_config
      #   @return [Configurator] the Rosette config to use.
      # @!attribute [r] repo_name
      #   @return [String] the name of the repo to process commits for.
      # @!attribute [r] logger
      #   @return [Logger] the logger to use.
      # @return [void]
      class CommitConductor
        # The status that indicates a commit is completely processed, i.e. has
        # no more stages to pass through.
        FINISHED_STATUS = Rosette::DataStores::PhraseStatus::TRANSLATED

        attr_reader :rosette_config, :repo_name, :logger

        def self.stage_classes
          # grab all classes that inherit from Stage
          @stage_classes ||= begin
            namespace = Rosette::Queuing::Commits
            namespace.constants
              .map { |const_sym| namespace.const_get(const_sym) }
              .select { |const| const < namespace::Stage }
          end
        end

        # Creates a new instance of +CommitConductor
        # @param [Configurator] rosette_config The Rosette config to use.
        # @param [String] repo_name The name of the repo to process commits for.
        # @param [Logger] logger The logger to use.
        # @return [CommitConductor]
        def initialize(rosette_config, repo_name, logger)
          @rosette_config = rosette_config
          @repo_name = repo_name
          @logger = logger
        end

        # Creates a new job for the commit and enqueues it on the configured
        # Rosette queue.
        #
        # @param [String] commit_id The commit to enqueue.
        # @return [void]
        def enqueue(commit_id)
          job = CommitJob.new(repo_name, commit_id)
          enqueue_job(job)
        end

        # Executes the current stage of the commit log and advances it to the
        # next. Also updates the commit log's status.
        #
        # @param [CommitLog] commit_log The commit log to advance.
        # @return [void]
        def advance(commit_log)
          create_stage_instance(commit_log).tap do |stage|
            stage.execute!
            return if finished?(stage)
            enqueue_job(stage.to_job)
          end
        end

        protected

        def finished?(stage)
          !stage || stage.commit_log.status == FINISHED_STATUS
        end

        def enqueue_job(job)
          rosette_config.queue.enqueue(job)
        end

        def create_stage_instance(commit_log)
          self.class.stage_classes.each do |stage_class|
            if stage = stage_class.for_commit_log(commit_log, rosette_config, logger)
              return stage
            end
          end
          nil
        end
      end

    end
  end
end
