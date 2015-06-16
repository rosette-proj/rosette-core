# encoding: UTF-8

require 'spec_helper'

include Rosette::Core::Commands

describe ExportCommand do
  let(:repo_name) { 'single_commit' }
  let(:locales) { %w(es de-DE ja-JP) }
  let(:phrase_model) { Rosette::DataStores::InMemoryDataStore::Phrase }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
      repo_config.add_locales(locales)
      repo_config.add_serializer('test', format: 'test/test')
    end
  end

  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }
  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:command) { ExportCommand.new(rosette_config) }

  before do
    CommitCommand.new(rosette_config)
      .set_repo_name(repo_name)
      .set_ref(commit_id)
      .execute

    command.set_repo_name(repo_name)
      .set_ref(commit_id)
      .set_locale(locales.first)
      .set_serializer('test/test')

    phrase_model.entries.each do |phrase|
      repo_config.tms.store_phrase(phrase, commit_id)
      repo_config.tms.auto_translate(command.send(:locale_obj), phrase)
    end
  end

  it 'exports translations from the given commit' do
    result = command.execute

    test_pairs = [
      "I'm a little teapot = i'may aay ittlelay eapottay",
      "Diamonds are a girl's best friend. = iamondsday areay aay irl'sgay estbay iendfray.",
      "string2 =  esttay ingstray 2"
    ]

    test_pairs.each do |test_pair|
      expect(result[:payload]).to include(test_pair)
    end
  end

  it 'includes basic information about the payload' do
    result = command.execute
    expect(result[:encoding]).to eq('UTF-8')
    expect(result[:translation_count]).to eq(8)
    expect(result[:base_64_encoded]).to eq(false)
    expect(result[:locale]).to eq(locales.first)
    expect(result[:paths]).to eq([])
    expect(result).to_not include(:checksum)
  end

  context 'with base 64 encoding option' do
    before do
      command.set_base_64_encode(true)
    end

    it 'base 64 encodes the payload' do
      result = command.execute
      expect(Base64.decode64(result[:payload])).to include(
        "I'm a little teapot = i'may aay ittlelay eapottay"
      )
    end
  end

  context 'with checksum option' do
    before do
      command.set_include_checksum(true)
    end

    it 'includes a checksum with the payload' do
      expect(command.execute).to include(:checksum)
    end
  end

  context 'with snapshot option' do
    before do
      command.set_include_snapshot(true)
    end

    it 'includes the snapshot' do
      expect(command.execute[:snapshot]).to eq(
        'first_file.txt' => commit_id,
        'folder/second_file.txt' => commit_id,
        'folder/with_metakeys.txt' => commit_id
      )
    end
  end

  context 'with a different encoding' do
    before do
      command.set_encoding(Encoding::UTF_16)
    end

    it 'includes the encoding alongside the payload' do
      expect(command.execute[:encoding]).to eq('UTF-16')
    end
  end
end
