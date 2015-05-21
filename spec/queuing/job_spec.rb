# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing

describe Job do
  let(:job_class) { Class.new(Job) }

  describe '.queue_name' do
    it 'returns the default queue name' do
      expect(job_class.queue_name).to eq('default')
    end

    it 'returns a custom queue name' do
      job_class.set_queue_name('foobar')
      expect(job_class.queue_name).to eq('foobar')
    end
  end

  describe '#set_delay' do
    let(:job) { job_class.new }

    it 'checks the delay is set to zero by default' do
      expect(job.delay).to eq(0)
    end

    it 'sets the delay' do
      job.set_delay(10)
      expect(job.delay).to eq(10)
    end
  end
end
