# encoding: UTF-8

module Rosette
  module Core

    class Configurator
      attr_reader :repo_configs, :datastore

      def initialize
        @repo_configs = []
      end

      def add_repo(name)
        repo_configs << Rosette::Core::RepoConfig.new(name).tap do |repo_config|
          yield repo_config
        end
      end

      def get_repo(name)
        repo_configs.find { |rc| rc.name == name }
      end

      def use_datastore(datastore, options = {})
        @datastore = case datastore
          when String
            find_datastore_const(datastore).new(options)
          else
            datastore
        end
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
