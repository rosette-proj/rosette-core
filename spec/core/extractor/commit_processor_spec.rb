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
            expect(phrases.size).to eq(8)
            phrases.each { |phrase| fixture_commit.remove(phrase) }
          end
        end

        expect(fixture_commit).to_not have_more_phrases
        expect(error_reporter.errors).to be_empty
      end
    end

    it 'reports syntax errors if they occur' do
      allow_any_instance_of(Rosette::Extractors::Test::TestExtractor).to(
        receive(:each_function_call)
        .with(anything)
        .and_raise(
          Rosette::Core::SyntaxError.new(
            'nope', StandardError.new('error'), :txt
          )
        )
      )

      fixture.each_commit do |fixture_commit|
        processor.process_each_phrase(repo_name, fixture_commit.sha).to_a

        error_reporter.errors.tap do |errors|
          expect(errors.size).to eq(3)

          errors.each do |error|
            expect(error[:error].original_exception).to be_a(StandardError)
            expect(error[:error].message).to eq(
              "nope (txt): error (txt) in #{error[:error].file} at #{fixture_commit.sha}"
            )
            expect(error[:error].language).to eq(:txt)
            expect(error[:error].commit_id).to eq(fixture_commit.sha)
          end

          expect(errors.map { |e| e[:error].file }.sort).to eq([
            'first_file.txt',
            'folder/second_file.txt',
            'folder/with_metakeys.txt'
          ].sort)
        end
      end
    end
  end
end
