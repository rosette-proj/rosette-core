# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::DataStores

class CommitLogStatusTester
  include CommitLogStatus

  def initialize(initial_status)
    send('status=', initial_status)
  end

  def status=(new_status)
    if new_status
      @status = new_status

      aasm.set_current_state_with_persistence(
        new_status.to_sym
      )
    end
  end

  def status
    aasm.current_state.to_s
  end
end

describe CommitLogStatus do
  let(:instance) do
    CommitLogStatusTester.new(status)
  end

  context 'with a NOT_SEEN status' do
    let(:status) { PhraseStatus::NOT_SEEN }

    describe 'on fetch' do
      it 'transitions to FETCHED' do
        expect(instance.fetch).to be_truthy
        expect(instance.status).to eq(PhraseStatus::FETCHED)
      end
    end

    describe 'on extract' do
      it 'raises an error' do
        expect { instance.extract }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on push' do
      it 'raises an error' do
        expect { instance.push }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on finalize' do
      it 'raises an error' do
        expect { instance.finalize }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a FETCHED status' do
    let(:status) { PhraseStatus::FETCHED }

    describe 'on fetch' do
      it 'raises an error' do
        expect { instance.fetch }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on extract' do
      it 'transitions to EXTRACTED' do
        expect(instance.extract).to be_truthy
        expect(instance.status).to eq(PhraseStatus::EXTRACTED)
      end
    end

    describe 'on push' do
      it 'raises an error' do
        expect { instance.push }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on finalize' do
      it 'raises an error' do
        expect { instance.finalize }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with an EXTRACTED status' do
    let(:status) { PhraseStatus::EXTRACTED }

    describe 'on fetch' do
      it 'raises an error' do
        expect { instance.fetch }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on extract' do
      it 'raises an error' do
        expect { instance.extract }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on push' do
      it 'transitions to PUSHED' do
        expect(instance.push).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PUSHED)
      end
    end

    describe 'on finalize' do
      it 'transitions to FINALIZED' do
        expect(instance.finalize).to be_truthy
        expect(instance.status).to eq(PhraseStatus::FINALIZED)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a PUSHED status' do
    let(:status) { PhraseStatus::PUSHED }

    describe 'on fetch' do
      it 'raises an error' do
        expect { instance.fetch }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on extract' do
      it 'raises an error' do
        expect { instance.extract }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on push' do
      it 'stays PUSHED' do
        expect(instance.push).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PUSHED)
      end
    end

    describe 'on finalize' do
      it 'transitions to FINALIZED' do
        expect(instance.finalize).to be_truthy
        expect(instance.status).to eq(PhraseStatus::FINALIZED)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a FINALIZED status' do
    let(:status) { PhraseStatus::FINALIZED }

    describe 'on fetch' do
      it 'raises an error' do
        expect { instance.fetch }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on extract' do
      it 'raises an error' do
        expect { instance.extract }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on push' do
      it 'raises an error' do
        expect { instance.push }.to raise_error(AASM::InvalidTransition)
      end
    end

    describe 'on finalize' do
      it 'stays FINALIZED' do
        expect(instance.finalize).to be_truthy
        expect(instance.status).to eq(PhraseStatus::FINALIZED)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end
end
