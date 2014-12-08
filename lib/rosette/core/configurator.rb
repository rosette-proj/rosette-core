# encoding: UTF-8

require 'active_support'

module Rosette
  module Core

    class Configurator
      include Integrations::Integratable

      attr_reader :repo_configs, :datastore, :cache, :error_reporter

      def initialize
        @repo_configs = []
        @integrations = []
        @cache = ActiveSupport::Cache.lookup_store
        @error_reporter ||= PrintingErrorReporter.new(Rosette.logger)
      end

      def add_repo(name)
        repo_configs << Rosette::Core::RepoConfig.new(name).tap do |repo_config|
          yield repo_config
          repo_config.apply_integrations(repo_config)
        end
      end

      def get_repo(name)
        repo_configs.find { |rc| rc.name == name }
      end

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

      def use_error_reporter(reporter)
        @error_reporter = reporter
      end

      def use_cache(*args)
        @cache = ActiveSupport::Cache.lookup_store(args)
      end

      private

      def find_datastore_const(name)
        const_str = "#{Rosette::Core::StringUtils.camelize(name)}DataStore"

        if Rosette::DataStores.const_defined?(const_str)
          Rosette::DataStores.const_get(const_str)
        end
      end
    end

  end
end
