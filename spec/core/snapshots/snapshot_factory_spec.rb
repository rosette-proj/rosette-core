# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe SnapshotFactory do
  let(:factory_class) { SnapshotFactory }
  let(:repo_name) { 'fake_app' }
  let(:fixture) { load_repo_fixture(repo_name) }
  let(:commits) do
    fixture.git('rev-list --all').split("\n").reverse
  end

  let(:rosette_config) do
    Rosette.build_config do |config|
      config.add_repo(repo_name) do |repo_config|
        repo_config.set_path(fixture.working_dir.join('.git').to_s)
      end
    end
  end

  let(:repo_config) do
    rosette_config.get_repo(repo_name)
  end

  describe '#take_snapshot' do
    it 'returns the correct snapshot for the first commit' do
      factory = factory_class.new
        .set_repo_config(repo_config)
        .set_start_commit_id(commits.first)

      factory.take_snapshot.tap do |snapshot|
        expect(snapshot).to eq(
          'app/controllers/product_controller.txt' => commits.first,
          'app/models/product.txt' => commits.first,
          'app/views/product/edit.txt' => commits.first,
          'app/controllers/file.other' => commits.first
        )
      end
    end

    it 'raises an error if passed a non-staged progress reporter' do
      reporter = ::ProgressReporters::ProgressReporter.new

      factory = factory_class.new
        .set_repo_config(repo_config)
        .set_start_commit_id(commits.first)

      expect(lambda { factory.take_snapshot(reporter) }).to(
        raise_error(ArgumentError)
      )
    end

    context 'with a factory pointed at the last commit' do
      let(:factory) do
        factory_class.new
          .set_repo_config(repo_config)
          .set_start_commit_id(commits.last)
      end

      it 'returns the correct snapshot for the second commit' do
        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first,
            'app/models/product.txt' => commits.first,
            'app/views/product/edit.txt' => commits.first,
            'app/controllers/order_controller.txt' => commits.last,
            'app/models/order.txt' => commits.last,
            'app/models/line_item.txt' => commits.last,
            'app/views/order/index.txt' => commits.last,
            'app/controllers/file.other' => commits.first,
            'app/models/another_file.other' => commits.last
          )
        end
      end

      it 'only includes files with matching file extensions when asked' do
        repo_config.add_extractor('test/test') do |extractor_config|
          extractor_config.set_conditions do |conditions|
            conditions.match_file_extension('.other')
          end
        end

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/file.other' => commits.first,
            'app/models/another_file.other' => commits.last
          )
        end
      end

      it 'only includes files with matching paths when asked' do
        repo_config.add_extractor('test/test') do |extractor_config|
          extractor_config.set_conditions do |conditions|
            conditions.match_path('app/controllers')
          end
        end

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first,
            'app/controllers/order_controller.txt' => commits.last,
            'app/controllers/file.other' => commits.first
          )
        end
      end

      it 'supports combining multiple filters with a logical OR' do
        repo_config.add_extractor('test/test') do |extractor_config|
          extractor_config.set_conditions do |conditions|
            conditions.match_path('app/controllers').or(
              conditions.match_file_extension('.other')
            )
          end
        end

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/product_controller.txt' => commits.first,
            'app/controllers/order_controller.txt' => commits.last,
            'app/controllers/file.other' => commits.first,
            'app/models/another_file.other' => commits.last
          )
        end
      end

      it 'supports combining multiple filters with a logical AND' do
        repo_config.add_extractor('test/test') do |extractor_config|
          extractor_config.set_conditions do |conditions|
            conditions.match_path('app/controllers').and(
              conditions.match_file_extension('.other')
            )
          end
        end

        factory.take_snapshot.tap do |snapshot|
          expect(snapshot).to eq(
            'app/controllers/file.other' => commits.first
          )
        end
      end
    end
  end
end
