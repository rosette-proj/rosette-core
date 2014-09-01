# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe PrintingErrorReporter do
  class Collector
    attr_reader :messages

    def initialize
      @messages = []
    end

    def write(message)
      @messages << message
    end
  end

  let(:error) do
    begin
      raise StandardError, 'jelly beans'
    rescue => e
      e
    end
  end

  let(:collector) { Collector.new }
  let(:reporter) { PrintingErrorReporter.new(collector) }

  describe '#report_error' do
    it 'prints the error message' do
      reporter.report_error(error)
      expect(collector.messages.size).to eq(1)
      expect(collector.messages).to include("jelly beans\n")
    end

    context 'with a reporter that prints a stack trace' do
      let(:reporter) do
        PrintingErrorReporter.new(
          collector, print_stack_trace: true
        )
      end

      it 'prints a stack trace along with the error message' do
        reporter.report_error(error)
        expect(collector.messages).to include("jelly beans\n")
        expect(collector.messages.size).to be > 1

        trace_message = collector.messages.find do |message|
          message =~ /printing_error_reporter_spec.rb:[\d]+/
        end

        expect(trace_message).to_not be_nil
      end
    end
  end
end
