# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe CommitProcessor do
  let(:repo_name) { 'single_commit' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:error_reporter) { BufferedErrorReporter.new }

  let(:processor) do
    CommitProcessor.new(fixture.config, error_reporter)
  end

  let(:commits) do
    fixture.git('rev-list --abbrev --all').split("\n")
  end

  describe '#process_each_phrase' do
    it 'extracts each phrase in the commit and returns an enum' do
      expect(commits.size).to eq(1)

      processor.process_each_phrase(repo_name, commits.first).tap do |phrase_enum|
        expect(phrase_enum).to be_a(Enumerator)

        phrase_enum.to_a.tap do |phrases|
          expect(phrases.size).to eq(6)

          # Loop through all phrases in the properties list. Remove the corresponding
          # phrase objects from the extraction results if they match. If the right
          # phrases were extracted, the extraction results should be empty.
          fixture.properties[:phrases].each_pair do |expected_file, expected_phrase_list|
            phrases.delete_if do |actual_phrase|
              actual_phrase.file == expected_file &&
                expected_phrase_list.include?(actual_phrase.key)
            end
          end

          expect(phrases).to be_empty
          expect(error_reporter.errors).to be_empty
        end
      end
    end

    it 'reports syntax errors if they occur' do
      any_instance_of(Rosette::Extractors::Test::TestExtractor) do |extractor|
        stub(extractor).each_function_call(anything) do
          raise Rosette::Core::SyntaxError.new('nope', :error, :txt)
        end
      end

      processor.process_each_phrase(repo_name, commits.first).to_a

      error_reporter.errors.tap do |errors|
        expect(errors.size).to eq(2)

        errors.each do |error|
          expect(error.original_exception).to eq(:error)
          expect(error.message).to eq('nope')
          expect(error.language).to eq(:txt)
          expect(error.commit_id).to eq(commits.first)
        end

        expect(errors.first.file).to eq('first_file.txt')
        expect(errors.last.file).to eq('folder/second_file.txt')
      end
    end
  end
end
