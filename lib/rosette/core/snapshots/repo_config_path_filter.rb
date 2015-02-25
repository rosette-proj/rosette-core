# encoding: UTF-8

java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core

    # A jgit tree filter that filters by the path rules specified in the given
    # {RepoConfig}.
    #
    # @example
    #   filter = RepoConfigPathFilter.create(repo_config)
    #   factory = Rosette::Core::SnapshotFactory.new
    #     .set_repo('my_repo')
    #
    #   factory.add_filter(filter)
    #   factory.take_snapshot(...)
    #
    # @!attribute [rw] repo_config
    #   @return [Array<String>] the configuration to use when filtering paths
    class RepoConfigPathFilter < TreeFilter
      # Creates a new filter with the given repo config.
      #
      # @param [RepoConfig] repo_config The configuration to use when
      #   filtering paths
      # @return [FileTypeFilter]
      def self.create(repo_config)
        # Do this because jruby is dumb (i.e. doesn't let you override java
        # constructors)
        new.tap do |obj|
          obj.repo_config = repo_config
        end
      end

      attr_accessor :repo_config

      # Overridden. Returns true if the current file matches false otherwise.
      # Generally this method is only called by Jgit internals.
      #
      # @param [Java::OrgEclipseJgitTreewalk::TreeWalk] walker The walker with
      #   the current file.
      # @return [Boolean]
      def include(walker)
        if walker.isSubtree
          true
        else
          path = walker.getPathString

          if repo_config.extractor_configs.size > 0
            repo_config.extractor_configs.any? do |extractor_config|
              extractor_config.matches?(path)
            end
          else
            true
          end
        end
      end

      # Returns true if this filter should be applied recursively, false otherwise.
      # For this particular filter, always returns true.
      #
      # @return [Boolean]
      def shouldBeRecursive
        true
      end

      # Clones this filter. For this particular filter, always returns self.
      #
      # @return [self]
      def clone
        self
      end

      # Returns a string representation of this filter.
      #
      # @return [String]
      def to_s
        "REPO_CONFIG_FILTER"
      end
    end

  end
end
