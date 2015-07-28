# encoding: UTF-8

module Rosette
  module Queuing

    # Configuration used to initialize a queue implementation.
    #
    # @!attribute [r] queue_options
    #   @return [Hash] a hash of options to be used by the queue implementation.
    # @!attribute [r] queue_configs
    #   @return [Array] an array of queue config objects. These classes are
    #     provided by each type of queue. For example, the queue that processes
    #     commits (see [Rosette::Queuing::Commits]) defines its own configurator
    #     that gets instantiated and added to this array.
    class QueueConfigurator
      attr_reader :queue_options, :queue_configs

      # Creates a new +QueueConfigurator+ instance.
      #
      # @return [QueueConfigurator]
      def initialize
        @queue_options = {}
        @queue_configs = []
      end

      # Sets an options hash that will be used to initialize the underlying
      # queue implementation (eg. resque, sidekiq, etc).
      #
      # @param [Hash] options The options hash to use to initialize the
      #   underlying queue implementation (eg. resque, sidekiq, etc).
      # @return [void]
      def set_queue_options(options = {})
        @queue_options = options
      end

      # Configures and adds a queue to process jobs from. Note that the term
      # "queue" here refers to a sequence of jobs, not a queue implementation.
      #
      # @param [String] queue_name The name of the queue to configure.
      # @return [void]
      def enable_queue(queue_name)
        if const = find_queue_configurator_const(queue_name)
          config = const.new(queue_name)
          yield config if block_given?
          queue_configs << config
        else
          raise ArgumentError, "'#{queue_name}' couldn't be found."
        end
      end

      # Looks up a queue configuration object by name.
      #
      # @param [String] queue_name The name of the queue to look up.
      # @return [Object, nil] The queue config object, or +nil+ if none could
      #   be found.
      def get_queue_config(queue_name)
        queue_configs.find { |q| q.name == queue_name }
      end

      protected

      def find_queue_configurator_const(name)
        const_str = Rosette::Core::StringUtils.camelize(name)

        if Rosette::Queuing.const_defined?(const_str)
          mod = Rosette::Queuing.const_get(const_str)

          if mod.const_defined?(:"#{const_str}QueueConfigurator")
            mod.const_get(:"#{const_str}QueueConfigurator")
          end
        end
      end
    end

  end
end
