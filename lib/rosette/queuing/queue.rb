# encoding: UTF-8

module Rosette
  module Queuing

    # Base class for Rosette queue implementations. Really just an interface.
    class Queue
      # Creates a new queue instance. Options vary per implementation.
      #
      # @param [Hash] options A hash of options used by the underlying
      #   queue implementation.
      # @return [Queue]
      def initialize(options = {})
      end

      # Add a job instance to the queue. If not implemented by a derived class,
      # raises +NotImplementedError+.
      #
      # @param [Job] job The job to enqueue.
      # @return [void]
      def enqueue(job)
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end
    end

  end
end
