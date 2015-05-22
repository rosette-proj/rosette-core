# encoding: UTF-8

module Rosette
  module Queuing

    # Base class for Rosette queue worker implementations. Really just an
    # interface.
    class Worker
      # Creates a new worker instance. Options vary per implementation.
      #
      # @param [Configurator] rosette_config The Rosette config to use.
      # @param [Logger] logger The logger to print messages with.
      # @param [Hash] options A hash of options used by the underlying
      #   queue implementation.
      # @return [Worker]
      def initialize(rosette_config, logger, options = {})
      end

      # Tells this worker to start processing jobs. Should block. If not
      # implemented by the derived class, raises +NotImplementedError+.
      #
      # @return [void]
      def start
        raise NotImplementedError,
          'expected to be implemented in derived classes'
      end
    end

  end
end
