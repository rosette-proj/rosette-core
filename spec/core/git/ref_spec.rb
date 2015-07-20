# encoding: UTF-8

require 'spec_helper'

include Rosette::Core

describe Ref do
  describe '.parse' do
    it 'parses remotes' do
      ref = Ref.parse('refs/remotes/origin/foobar')
      expect(ref).to be_a(Remote)
    end

    it 'parses heads' do
      ref = Ref.parse('refs/heads/foobar')
      expect(ref).to be_a(Head)
    end

    it 'parses tags' do
      ref = Ref.parse('refs/tags/foobar')
      expect(ref).to be_a(Tag)
    end
  end
end

describe Remote do
  describe '.create_from' do
    it 'creates a new remote ref' do
      remote = Remote.create_from(%w(remotes origin foobar))
      expect(remote.remote).to eq('origin')
      expect(remote.name).to eq('foobar')
    end
  end

  context 'with a remote' do
    let(:remote) { Remote.new('origin', 'foobar') }

    describe '#type' do
      it 'returns the correct type' do
        expect(remote.type).to eq(:remote)
      end
    end

    describe '#to_s' do
      it 'constructs a string representation' do
        expect(remote.to_s).to eq('refs/remotes/origin/foobar')
      end
    end

    it 'responds correctly to query methods' do
      expect(remote).to be_remote
      expect(remote).to_not be_head
      expect(remote).to_not be_tag
    end
  end
end

describe Head do
  describe '.create_from' do
    it 'creates a new head' do
      head = Head.create_from(%w(heads foobar))
      expect(head.name).to eq('foobar')
    end
  end

  context 'with a head' do
    let(:head) { Head.new('foobar') }

    describe '#type' do
      it 'returns the correct type' do
        expect(head.type).to eq(:head)
      end
    end

    describe '#to_s' do
      it 'constructs a string representation' do
        expect(head.to_s).to eq('refs/heads/foobar')
      end
    end

    it 'responds correctly to query methods' do
      expect(head).to be_head
      expect(head).to_not be_remote
      expect(head).to_not be_tag
    end
  end
end

describe Tag do
  describe '.create_from' do
    it 'creates a new tag' do
      tag = Tag.create_from(%w(tags foobar))
      expect(tag.name).to eq('foobar')
    end
  end

  context 'with a tag' do
    let(:tag) { Tag.new('foobar') }

    describe '#type' do
      it 'returns the correct type' do
        expect(tag.type).to eq(:tag)
      end
    end

    describe '#to_s' do
      it 'constructs a string representation' do
        expect(tag.to_s).to eq('refs/tags/foobar')
      end
    end

    it 'responds correctly to query methods' do
      expect(tag).to be_tag
      expect(tag).to_not be_head
      expect(tag).to_not be_remote
    end
  end
end
