# encoding: UTF-8

require 'progress-reporters'

java_import 'org.eclipse.jgit.lib.Constants'
java_import 'org.eclipse.jgit.diff.DiffEntry'
java_import 'org.eclipse.jgit.lib.ObjectInserter'
java_import 'org.eclipse.jgit.lib.Ref'
java_import 'org.eclipse.jgit.lib.Repository'
java_import 'org.eclipse.jgit.revwalk.RevCommit'
java_import 'org.eclipse.jgit.revwalk.RevSort'
java_import 'org.eclipse.jgit.revwalk.RevWalk'
java_import 'org.eclipse.jgit.treewalk.filter.OrTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.AndTreeFilter'
java_import 'org.eclipse.jgit.treewalk.filter.PathFilterGroup'
java_import 'org.eclipse.jgit.treewalk.TreeWalk'

module Rosette
  module Core
    class SnapshotFactory

      DEFAULT_FILTER_STRATEGY = :or
      AVAILABLE_FILTER_STRATEGIES = [:and, :or]

      attr_reader :repo, :start_commit, :filters, :filter_strategy

      attr_reader :file_walker
      private :file_walker

      def initialize(repo, start_commit)
        @repo = repo
        @start_commit = start_commit
        @file_walker = TreeWalk.new(repo.jgit_repo)
        @filter_strategy = :or
        @filters ||= []
        reset
      end

      def set_filter_strategy(strategy)
        if AVAILABLE_FILTER_STRATEGIES.include?(strategy)
          @filter_strategy = strategy
          self
        else
          raise ArgumentError, "'#{strategy}' is not a valid filter strategy."
        end
      end

      def add_filter(filter)
        filters << filter
        self
      end

      def filter_by_extensions(extensions)
        add_filter(FileTypeFilter.create(extensions))
        self
      end

      def filter_by_paths(paths)
        add_filter(PathFilterGroup.createFromStrings(Array(paths)))
        self
      end

      def take_snapshot(progress_reporter = nil_progress_reporter)
        unless progress_reporter.respond_to?(:change_stage)
          raise ArgumentError, "Progress reporter must be able to change stage."\
            "Consider using a #{staged_progress_reporter_class.name}."
        end

        file_walker.setFilter(compile_filter)
        total_files = file_count

        progress_reporter.set_stage(:finding_objects)
        blob_ids = blob_ids_from_walker(file_walker, progress_reporter, total_files)
        progress_reporter.report_stage_finished(total_files, total_files)

        progress_reporter.change_stage(:finding_commit_ids)
        commits_for_blobs(blob_ids, progress_reporter).tap do
          progress_reporter.report_stage_finished(total_files, total_files)
          progress_reporter.report_complete
          reset
        end
      end

      def file_count
        file_walker.setFilter(compile_filter)
        each_file_in(file_walker).count.tap { reset }
      end

      private

      def commits_for_blobs(blob_ids, progress_reporter)
        rev_walker = RevWalk.new(repo.jgit_repo).tap do |walker|
          walker.markStart(walker.lookupCommit(start_commit.getId))
          walker.sort(RevSort::REVERSE)
        end

        found_blobs = 0

        commits = rev_walker.each_with_object({}) do |cur_rev, file_shas|
          repo.rev_diff_with_parent(cur_rev).each do |entry|
            sha1 = entry.getId(DiffEntry::Side::NEW).toObjectId.getName

            if blob_ids.include?(sha1) && !file_shas.include?(entry.getNewPath)
              file_shas[entry.getNewPath] = cur_rev.getName
              found_blobs += 1
            end

            progress_reporter.report_progress(found_blobs, blob_ids.size)
          end
        end

        rev_walker.dispose
        commits
      end

      def reset
        file_walker.reset
        file_walker.addTree(start_commit.getTree)
        file_walker.setRecursive(true)
      end

      def compile_filter
        if filters.size == 1
          filters.first
        elsif filters.size >= 2
          case filter_strategy
            when :or
              OrTreeFilter.create(filters)
            when :and
              AndTreeFilter.create(filters)
          end
        end
      end

      def blob_ids_from_walker(file_walker, progress_reporter, total_files)
        each_file_in(file_walker).map.with_index do |walker, idx|
          stream = repo.jgit_repo.open(walker.getObjectId(0)).openStream
          blob_id_from_stream(stream).tap do
            progress_reporter.report_progress(idx, total_files)
          end
        end
      end

      def blob_id_from_stream(stream)
        object_formatter.idFor(Constants::OBJ_BLOB, stream.getSize(), stream).getName
      end

      def object_formatter
        @object_formatter ||= ObjectInserter::Formatter.new
      end

      def diff_formatter
        @diff_formatter ||= DiffFormatter.new(NullOutputStream::INSTANCE).tap do |formatter|
          formatter.setRepository(repo.jgit_repo)
        end
      end

      def each_file_in(tree_walk)
        if block_given?
          while tree_walk.next
            yield tree_walk
          end
        else
          to_enum(__method__, tree_walk)
        end
      end

      def staged_progress_reporter_class
        ::ProgressReporters::StagedProgressReporter
      end

      def nil_progress_reporter
        ::ProgressReporters::NilStagedProgressReporter.instance
      end

    end
  end
end
