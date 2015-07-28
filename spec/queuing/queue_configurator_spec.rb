# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing

describe QueueConfigurator do
  let(:configurator) { QueueConfigurator.new }

  describe '#enable_queue' do
    it "raises an error if the queue can't be determined" do
      expect { configurator.enable_queue('foo') }.to raise_error
    end

    it 'adds the queue config to the list of configured queues' do
      expect { configurator.enable_queue('commits') }.to(
        change { configurator.queue_configs.size }.from(0).to(1)
      )

      expect(configurator.queue_configs.first).to(
        be_a(Commits::CommitsQueueConfigurator)
      )
    end
  end

  context 'with a queue configured' do
    let(:queue_name) { 'commits' }

    before(:each) do
      configurator.enable_queue(queue_name)
    end

    describe '#get_queue_config' do
      it 'gets the queue by name' do
        queue_config = configurator.get_queue_config(queue_name)
        expect(queue_config).to be_a(Commits::CommitsQueueConfigurator)
      end

      it 'returns nil if no config could be found' do
        expect(configurator.get_queue_config('foo')).to be_nil
      end
    end
  end
end
