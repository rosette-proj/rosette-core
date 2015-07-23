# encoding: UTF-8

require 'active_support'
require 'rosette/integrations'

module Rosette
  module Core

    # Builds Rosette configuration. Usually used via +Rosette#build_config+.
    #
    # @see Rosette
    #
    # @example
    #   config = Rosette.build_config do |config|
    #     config.add_repo do |repo_config|
    #       ...
    #     end
    #   end
    #
    # @!attribute [r] repo_configs
    #   @return [Array<RepoConfig>] The current array of configured repo
    #     configs.
    # @!attribute [r] datastore
    #   @return [DataStore] The datastore to store phrases and translations in.
    # @!attribute [r] cache
    #   @return [#fetch] The cache instance to use (can be +nil+).
    # @!attribute [r] queue
    #   @return [Rosette::Queuing::Queue] The queue implementation to use.
    # @!attribute [r] error_reporter
    #   @return [ErrorReporter] The error reporter to use if errors occur.
    class Configurator
      include Integrations::Integratable

      attr_reader :repo_configs, :datastore, :cache, :queue, :error_reporter

      # Creates a new config object.
      def initialize
        @repo_configs = []
        @integrations = []
        @cache = ActiveSupport::Cache.lookup_store
        @error_reporter ||= PrintingErrorReporter.new(STDOUT)
      end

      # Adds a repo config.
      #
      # @param [String] name The semantic name of the repo.
      # @return [void]
      def add_repo(name)
        repo_configs << Rosette::Core::RepoConfig.new(name, self).tap do |repo_config|
          yield repo_config
          repo_config.apply_integrations(repo_config)
        end
      end

      # Retrieve a repo config by name.
      #
      # @param [String] name The semantic name of the repo to retrieve.
      # @return [RepoConfig]
      def get_repo(name)
        repo_configs.find { |rc| rc.name == name }
      end

      # Set the datastore to use to store phrases and translations.
      #
      # @param [Const, String] datastore The datastore to use. When this
      #   parameter is a string, +use_datastore+ will try to look up the
      #   corresponding constant with a "DataStore" suffix. If it's a constant
      #   instead, the constant is used without modifications.
      # @param [Hash] options A hash of options passed to the datastore's
      #   constructor.
      # @return [void]
      def use_datastore(datastore, options = {})
        const = case datastore
          when String
            if const = find_datastore_const(datastore)
              const
            else
              raise ArgumentError, "'#{datastore}' couldn't be found."
            end
          when Class
            datastore
          else
            raise ArgumentError, "'#{datastore}' must be a String or Class."
        end

        @datastore = const.new(options)
        nil
      end

      # Set the error reporter this config should use to report errors. The
      # default error reporter is an instance of {PrintingErrorReporter}.
      #
      # @param [ErrorReporter] reporter The error reporter.
      # @return [void]
      def use_error_reporter(reporter)
        @error_reporter = reporter
      end

      # Set the cache implementation. This must be one of the offerings in
      # +ActiveSupport::Cache+:
      # http://api.rubyonrails.org/classes/ActiveSupport/Cache.html
      #
      # @param [*] args The args to pass to ActiveSupport::Cache#lookup_store:
      #   http://api.rubyonrails.org/classes/ActiveSupport/Cache.html#method-c-lookup_store
      # @return [void]
      def use_cache(*args)
        @cache = ActiveSupport::Cache.lookup_store(args)
      end

      # Set the queue implementation. Queues must implement the
      # [Rosette::Queuing::Queue] interface.
      #
      # @param [Const, String] queue The queue to use. When this parameter
      #   is a string, +use_queue+ will try to look up the corresponding
      #   constant with a "Queue" suffix. If it's a constant instead, the
      #   constant is used without modifications.
      # @param [Hash] options A hash of options passed to the queue's
      #   constructor.
      # @return [void]
      def use_queue(queue)
        const = case queue
          when String
            if const = find_queue_const(queue)
              const
            else
              raise ArgumentError, "'#{queue}' couldn't be found."
            end
          when Class
            queue
          else
            raise ArgumentError, "'#{queue}' must be a String or Class."
        end

        configurator = Rosette::Queuing::QueueConfigurator.new
        yield configurator if block_given?
        @queue = const.new(configurator)
        nil
      end

      private

      def find_datastore_const(name)
        const_str = "#{Rosette::Core::StringUtils.camelize(name)}DataStore"

        if Rosette::DataStores.const_defined?(const_str)
          Rosette::DataStores.const_get(const_str)
        end
      end

      def find_queue_const(name)
        const_str = "#{Rosette::Core::StringUtils.camelize(name)}Queue"

        if Rosette::Queuing.const_defined?(const_str)
          Rosette::Queuing.const_get(const_str)::Queue
        end
      end
    end

  end
end
