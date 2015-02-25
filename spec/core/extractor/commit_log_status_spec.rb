# encoding: UTF-8

require 'spec_helper'

include Rosette::Core
include Rosette::DataStores

class CommitLogStatusTester
  include CommitLogStatus

  attr_accessor :state

  def initialize(status)
    @status = status
  end
end

describe CommitLogStatus do
  let(:instance) do
    CommitLogStatusTester.new(status)
  end

  context 'with an UNTRANSLATED status' do
    let(:status) { PhraseStatus::UNTRANSLATED }

    describe 'on push' do
      it 'transitions to PENDING' do
        expect(instance.push).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PENDING)
      end
    end

    describe 'on pull' do
      it 'returns false and has no effect' do
        expect(instance.pull).to be_falsy
        expect(instance.status).to eq(PhraseStatus::UNTRANSLATED)
      end
    end

    describe 'on complete' do
      it 'returns false and has no effect' do
        expect(instance.complete).to be_falsy
        expect(instance.status).to eq(PhraseStatus::UNTRANSLATED)
      end
    end

    describe 'on translate' do
      it 'returns false and has no effect' do
        expect(instance.translate).to be_falsy
        expect(instance.status).to eq(PhraseStatus::UNTRANSLATED)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a PENDING status' do
    let(:status) { PhraseStatus::PENDING }

    describe 'on push' do
      it 'stays PENDING' do
        expect(instance.push).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PENDING)
      end
    end

    describe 'on pull' do
      it 'transitions to PULLING' do
        expect(instance.pull).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLING)
      end
    end

    describe 'on complete' do
      it 'transitions to PULLED' do
        expect(instance.complete).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLING)
      end
    end

    describe 'on translate' do
      it 'returns false and has no effect' do
        expect(instance.translate).to be_falsy
        expect(instance.status).to eq(PhraseStatus::PENDING)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a PULLING status' do
    let(:status) { PhraseStatus::PULLING }

    describe 'on push' do
      it 'returns false and has no effect' do
        expect(instance.push).to be_falsy
        expect(instance.status).to eq(PhraseStatus::PULLING)
      end
    end

    describe 'on pull' do
      it 'stays PULLING' do
        expect(instance.pull).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLING)
      end
    end

    describe 'on complete' do
      it 'stays PULLING' do
        expect(instance.complete).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLING)
      end
    end

    describe 'on translate' do
      it 'transitions to PULLED' do
        expect(instance.translate).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLED)
      end
    end

    describe 'on missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a PULLED status' do
    let(:status) { PhraseStatus::PULLED }

    describe 'on push' do
      it 'returns false and has no effect' do
        expect(instance.push).to be_falsy
        expect(instance.status).to eq(PhraseStatus::PULLED)
      end
    end

    describe 'on pull' do
      it 'transitions to TRANSLATED' do
        expect(instance.pull).to be_truthy
        expect(instance.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    describe 'on complete' do
      it 'stays PULLED' do
        expect(instance.complete).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLED)
      end
    end

    describe 'on translate' do
      it 'stays PULLED' do
        expect(instance.translate).to be_truthy
        expect(instance.status).to eq(PhraseStatus::PULLED)
      end
    end

    describe 'missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end

  context 'with a TRANSLATED status' do
    let(:status) { PhraseStatus::TRANSLATED }

    describe 'on push' do
      it 'returns false and has no effect' do
        expect(instance.push).to be_falsy
        expect(instance.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    describe 'on pull' do
      it 'returns false and has no effect' do
        expect(instance.pull).to be_falsy
        expect(instance.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    describe 'on complete' do
      it 'stays TRANSLATED' do
        expect(instance.complete).to be_truthy
        expect(instance.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    describe 'on translate' do
      it 'stays TRANSLATED' do
        expect(instance.translate).to be_truthy
        expect(instance.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    describe 'missing' do
      it 'transitions to MISSING' do
        expect(instance.missing).to be_truthy
        expect(instance.status).to eq(PhraseStatus::MISSING)
      end
    end
  end
end
