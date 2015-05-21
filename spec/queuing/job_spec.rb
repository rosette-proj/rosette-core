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
end
