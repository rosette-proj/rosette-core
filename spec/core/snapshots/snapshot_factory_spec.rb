# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe SnapshotFactory do
  let(:factory_class) { SnapshotFactory }
  let(:repo_class) { Repo }
  let(:repo_name) { 'fake_app' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:repo) { repo_class.from_path(fixture.working_dir.join('.git').to_s) }
  let(:commits) do
    fixture.git('rev-list --all').split("\n").map do |sha|
      repo.get_rev_commit(sha)
    end.reverse
  end

  class StagedCollector
    attr_reader :reporter, :messages

    StageChangedArgs = Struct.new(:new_stage, :old_stage)
    StageFinishedArgs = Struct.new(:count, :total, :percentage, :stage)
    ProgressArgs = Struct.new(:count, :total, :percentage, :stage)

    def initialize
      @messages = []
      @reporter = ProgressReporters::StagedProgressReporter.new
        .on_stage_changed { |*args| @messages << StageChangedArgs.new(*args) }
        .on_stage_finished { |*args| @messages << StageFinishedArgs.new(*args) }
        .on_progress { |*args| @messages << ProgressArgs.new(*args) }
    end
  end

  describe '#take_snapshot' do
    it 'returns the correct snapshot for the first commit' do
      factory = factory_class.new(repo, commits.first)
      factory.take_snapshot.tap do |snapshot|
        expect(snapshot).to eq(
          'app/controllers/product_controller.txt' => commits.first.getName,
          'app/models/product.txt' => commits.first.getName,
          'app/views/product/edit.txt' => commits.first.getName,
          'app/controllers/file.other' => commits.first.getName
        )
      end
    end

    it 'raises an error if passed a non-staged progress reporter' do
      reporter = ::ProgressReporters::ProgressReporter.new
      factory = factory_class.new(repo, commits.first)
      expect(lambda { factory.take_snapshot(reporter) }).to raise_error(ArgumentError)
    end

    it 'reports stages to the progress reporter' do
      collector = StagedCollector.new
      factory = factory_class.new(repo, commits.first)
      factory.take_snapshot(collector.reporter)

      collector.messages.tap do |messages|
        messages[0..4].each_with_index do |message, idx|
          expect(message.stage).to eq(:finding_objects)
          expect(message.count).to eq(idx)
        end

        expect(messages[5].old_stage).to eq(:finding_objects)
        expect(messages[5].new_stage).to eq(:finding_commit_ids)

        messages[6..9].each_with_index do |message, idx|
          expect(message.stage).to eq(:finding_commit_ids)
          expect(message.count).to eq(idx + 1) # starts at 1, 0 is not logged
        end
      end
    end

    context 'with a factory pointed at the last commit' do
      let(:factory) { factory_class.new(repo, commits.last) }

      it 'returns the correct snapshot for the second commit' do
        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first.getName,
            'app/models/product.txt' => commits.first.getName,
            'app/views/product/edit.txt' => commits.first.getName,
            'app/controllers/order_controller.txt' => commits.last.getName,
            'app/models/order.txt' => commits.last.getName,
            'app/models/line_item.txt' => commits.last.getName,
            'app/views/order/index.txt' => commits.last.getName,
            'app/controllers/file.other' => commits.first.getName,
            'app/models/another_file.other' => commits.last.getName
          )
        end
      end

      it 'only includes files with matching file extensions when the file extension filter is enabled' do
        factory.filter_by_extensions(['.other'])
        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/file.other' => commits.first.getName,
            'app/models/another_file.other' => commits.last.getName
          )
        end
      end

      it 'only includes files matching the given paths when a path filter is enabled' do
        factory.filter_by_paths(['app/controllers'])
        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first.getName,
            'app/controllers/order_controller.txt' => commits.last.getName,
            'app/controllers/file.other' => commits.first.getName
          )
        end
      end

      it 'combines multiple filters with a logical OR' do
        factory
          .filter_by_extensions(['.other'])
          .filter_by_paths(['app/controllers'])

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first.getName,
            'app/controllers/order_controller.txt' => commits.last.getName,
            'app/controllers/file.other' => commits.first.getName,
            'app/models/another_file.other' => commits.last.getName
          )
        end
      end

      it 'combines multiple filters with a logical AND when the filter strategy is appropriately set' do
        factory
          .filter_by_extensions(['.other'])
          .filter_by_paths(['app/controllers'])
          .set_filter_strategy(:and)

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/file.other' => commits.first.getName
          )
        end
      end
    end
  end
end
