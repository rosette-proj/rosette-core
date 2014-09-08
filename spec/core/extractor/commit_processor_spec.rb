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

  describe '#process_each_phrase' do
    it 'extracts each phrase in the commit and returns an enum' do
      fixture.each_commit do |fixture_commit|
        processor.process_each_phrase(repo_name, fixture_commit.sha).tap do |phrase_enum|
          expect(phrase_enum).to be_a(Enumerator)

          phrase_enum.to_a.tap do |phrases|
            expect(phrases.size).to eq(6)
            phrases.each { |phrase| fixture_commit.remove(phrase) }
          end
        end

        expect(fixture_commit).to_not have_more_phrases
        expect(error_reporter.errors).to be_empty
      end
    end

    it 'reports syntax errors if they occur' do
      any_instance_of(Rosette::Extractors::Test::TestExtractor) do |extractor|
        stub(extractor).each_function_call(anything) do
          raise Rosette::Core::SyntaxError.new('nope', :error, :txt)
        end
      end

      fixture.each_commit do |fixture_commit|
        processor.process_each_phrase(repo_name, fixture_commit.sha).to_a

        error_reporter.errors.tap do |errors|
          expect(errors.size).to eq(2)

          errors.each do |error|
            expect(error.original_exception).to eq(:error)
            expect(error.message).to eq('nope')
            expect(error.language).to eq(:txt)
            expect(error.commit_id).to eq(fixture_commit.sha)
          end

          expect(errors.first.file).to eq('first_file.txt')
          expect(errors.last.file).to eq('folder/second_file.txt')
        end
      end
    end
  end
end
