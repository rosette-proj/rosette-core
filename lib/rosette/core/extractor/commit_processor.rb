# encoding: UTF-8

java_import 'org.eclipse.jgit.revwalk.RevWalk'

module Rosette
  module Core

    # This class tries to be thread-safe
    class CommitProcessor
      attr_reader :config, :error_reporter

      def initialize(config, error_reporter = NilErrorReporter.instance)
        @config = config
        @error_reporter = error_reporter
      end

      # can throw: org.eclipse.jgit.errors.MissingObjectException
      def process_each_phrase(repo_name, commit_ref)
        if block_given?
          repo_config = config.get_repo(repo_name)
          rev_walk = RevWalk.new(repo_config.repo.jgit_repo)
          diff_finder = DiffFinder.new(repo_config.repo.jgit_repo, rev_walk)
          commit = repo_config.repo.get_rev_commit(commit_ref, rev_walk)

          diff_finder.diff_with_parent(commit).each do |diff_entry|
            process_diff_entry(diff_entry, repo_config, commit) do |phrase|
              yield phrase
            end
          end
        else
          to_enum(__method__, repo_name, commit_ref)
        end
      end

      protected

      def process_diff_entry(diff_entry, repo_config, commit)
        repo_config.get_extractor_configs(diff_entry.getNewPath).each do |extractor_config|
          source_code = read_object_from_entry(diff_entry, repo_config, extractor_config)
          line_numbers_to_author = repo_config.repo.blame(diff_entry.getNewPath, commit.getId.name)

          begin
            extractor_config.extractor.extract_each_from(source_code) do |phrase, line_number|
              phrase.file = diff_entry.getNewPath
              phrase.commit_id = commit.getId.name
              author_identity = line_numbers_to_author[line_number - 1]
              phrase.author_name = author_identity.getName
              phrase.author_email = author_identity.getEmailAddress
              phrase.line_number = line_number
              yield phrase
            end
          rescue SyntaxError => e
            error_reporter.report_error(
              ExtractionSyntaxError.new(
                e.message, e.original_exception, e.language,
                diff_entry.getNewPath, commit.getId.name
              )
            )
          end
        end
      end

      def read_object_from_entry(diff_entry, repo_config, extractor_config)
        object_reader = repo_config.repo.jgit_repo.newObjectReader
        bytes = object_reader.open(diff_entry.getNewId.toObjectId).getBytes
        Java::JavaLang::String.new(bytes, extractor_config.encoding.to_s).to_s
      end
    end

  end
end
