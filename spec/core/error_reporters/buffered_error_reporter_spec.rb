# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe BufferedErrorReporter do
  let(:error) { StandardError.new('jelly beans') }
  let(:options) { { foo: 'bar' } }
  let(:reporter) { BufferedErrorReporter.new }

  describe '#report_error' do
    it 'should log each error' do
      reporter.report_error(error, options)
      expect(reporter.errors.size).to eq(1)

      reporter.errors.first.tap do |err|
        expect(err.keys).to eq([:error, :options])
        expect(err[:error]).to eq(error)
        expect(err[:options]).to eq(options)
      end
    end
  end

  context 'with a reported error' do
    before(:each) do
      reporter.report_error(error, options)
    end

    describe '#reset' do
      it 'should clear the error list' do
        reporter.reset
        expect(reporter.errors).to be_empty
      end
    end

    describe '#errors_found?' do
      it 'returns true if errors have been reported, false otherwise' do
        expect(reporter.errors_found?).to be_truthy
        reporter.reset
        expect(reporter.errors_found?).to be_falsey
      end
    end

    describe '#each_error' do
      it 'yields each error if given a block' do
        reporter.each_error do |cur_error, opts|
          expect(cur_error).to eq(error)
          expect(opts).to eq(options)
        end
      end

      it 'returns an enumerator if not given a block' do
        reporter.each_error.tap do |enum|
          expect(enum).to be_a(Enumerator)
          expect(enum.to_a).to include([error, options])
        end
      end
    end
  end
end
