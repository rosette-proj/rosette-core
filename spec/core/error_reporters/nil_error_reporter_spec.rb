# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe NilErrorReporter do
  let(:error) { StandardError.new('jelly beans') }
  let(:reporter) { NilErrorReporter.instance }

  describe '#report_error' do
    it 'should respond to the #report_error method' do
      reporter.report_error(error)
    end
  end
end
