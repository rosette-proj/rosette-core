# encoding: UTF-8

java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'

module Rosette
  module Core

    # A jgit tree filter that filters by file extension.
    #
    # @example
    #   filter = FileTypeFilter.create(['.yml', '.yaml'])
    #   factory = Rosette::Core::SnapshotFactory.new
    #     .set_repo('my_repo')
    #
    #   factory.add_filter(filter)
    #   factory.take_snapshot(...)
    #
    # @!attribute [rw] extensions
    #   @return [Array<String>] the extensions to filter.
    class FileTypeFilter < TreeFilter
      # Creates a new filter with the given extensions.
      #
      # @param [Array<String>] extensions The list of file extensions to
      #   filter by.
      # @return [FileTypeFilter]
      def self.create(extensions)
        # Do this because jruby is dumb (i.e. doesn't let you override java
        # constructors)
        new.tap do |obj|
          obj.extensions = extensions
        end
      end

      attr_accessor :extensions

      # Overridden. Returns true if the current file has a matching extension,
      # false otherwise. Generally this method is only called by Jgit internals.
      #
      # @param [Java::OrgEclipseJgitTreewalk::TreeWalk] walker The walker with
      #   the current file.
      # @return [Boolean]
      def include(walker)
        if walker.isSubtree
          true
        else
          walker_ext = File.extname(walker.getPathString)

          extensions.each do |ext|
            return true if walker_ext == ext
          end

          false
        end
      end

      # Returns true if this filter should be applied recursively, false otherwise.
      # For this filter, always returns true.
      #
      # @return [Boolean]
      def shouldBeRecursive
        true
      end

      # Clones this filter. For this filter, always returns self.
      #
      # @return [self]
      def clone
        self
      end

      # Returns a string representation of this filter.
      #
      # @return [String]
      def to_s
        "EXTENSIONS(\"#{extensions.join(',')}\")"
      end
    end

  end
end
