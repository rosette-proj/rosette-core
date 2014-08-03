# encoding: UTF-8

java_import 'org.eclipse.jgit.treewalk.TreeWalk'
java_import 'org.eclipse.jgit.treewalk.filter.TreeFilter'
java_import 'org.eclipse.jgit.util.StringUtils'

module Rosette
  module Core

    class FileTypeFilter < TreeFilter
      def self.create(extensions)
        # do this because jruby is dumb
        new.tap do |obj|
          obj.extensions = extensions
        end
      end

      attr_accessor :extensions

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

      def shouldBeRecursive
        true
      end

      def clone
        self
      end

      def to_s
        "EXTENSIONS(\"#{extensions.join(',')}\")"
      end
    end

  end
end