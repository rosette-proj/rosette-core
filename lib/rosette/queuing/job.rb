# encoding: UTF-8

module Rosette
  module Queuing

    # Base class for jobs that can be run on a Rosette queue implementation.
    class Job
      # The name of the queue to use when no custom queue name is specified.
      DEFAULT_QUEUE_NAME = 'default'

      class << self
        # Returns the name of the queue this job will be run in. For
        # implementations that don't offer named queues, this value should be
        # ignored.
        #
        # @return [String] The name of the queue.
        def queue_name
          @queue_name || DEFAULT_QUEUE_NAME
        end

        # Sets the name of the queue this job will be run in. Implementations
        # that don't offer named queues shouldn't need to call this method,
        # although nothing bad will happen if they do.
        #
        # @param [String] queue_name The name of the queue to run the job in.
        # @return [void]
        def set_queue_name(queue_name)
          @queue_name = queue_name
        end
      end

      # Performs this job's task.
      #
      # @param [Configurator] rosette_config The rosette config to pass to the
      #   job when executing.
      # @param [Logger] logger The logger to pass to the job when executing.
      # @return [void]
      def work(rosette_config, logger)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end

      # Gets an array of the arguments to use to re-create this job later. Most
      # implementations will expect these arguments to be serializable in some
      # way so they can be stored in a cache or database.
      #
      # @return [Array<Object>] the list of job arguments.
      def to_args
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end
    end

  end
end
