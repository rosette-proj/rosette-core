# encoding: UTF-8

require 'spec_helper'

include Rosette::Queuing::Commits
include Rosette::DataStores

describe PullStage do
  let(:repo_name) { 'single_commit' }
  let(:commit_id) { fixture.repo.git('rev-parse HEAD').strip }

  let(:fixture) do
    load_repo_fixture(repo_name) do |config, repo_config|
      config.use_datastore('in-memory')
      repo_config.use_tms('test')
      repo_config.add_locales(%w(pt-BR ko-KR es))
    end
  end

  let(:rosette_config) { fixture.config }
  let(:repo_config) { rosette_config.get_repo(repo_name) }
  let(:logger) { NullLogger.new }

  let(:commit_log) do
    InMemoryDataStore::CommitLog.create(
      status: PhraseStatus::FETCHED,
      repo_name: repo_name,
      commit_id: commit_id,
      phrase_count: 0,
      commit_datetime: nil
    )
  end

  let(:stage) do
    PullStage.new(rosette_config, repo_config, logger, commit_log)
  end

  describe '#to_job' do
    it 'creates a commit job with a delay' do
      expect(stage.to_job.delay).to be > 0
    end
  end

  describe '#execute!' do
    before(:each) do
      args = [rosette_config, repo_config, logger, commit_log]
      ExtractStage.new(*args).execute!
      PushStage.new(*args).execute!
    end

    context 'with a few strings translated in each language' do
      before(:each) do
        repo_config.locales.each do |locale|
          InMemoryDataStore::Phrase.take(2).each do |phrase|
            repo_config.tms.auto_translate(locale, phrase)
          end
        end
      end

      it 'creates translation entries in the datastore' do
        stage.execute!

        repo_config.locales.each do |locale|
          count = InMemoryDataStore::Translation.entries.count do |trans|
            trans.phrase.commit_id == commit_id &&
              trans.locale == locale.code
          end

          expect(count).to eq(2)
        end
      end

      it 'creates commit log locale entries' do
        stage.execute!
        entries = InMemoryDataStore::CommitLogLocale.entries

        expect(entries.map(&:locale).sort).to(
          eq(repo_config.locales.map(&:code).sort)
        )

        entries.each do |entry|
          expect(entry.commit_id).to eq(commit_id)
          expect(entry.translated_count).to eq(2)
        end
      end

      it "doesn't pull translations if they haven't changed since the last pull" do
        stage.execute!
        expect(InMemoryDataStore::Translation.entries.size).to eq(6)
        InMemoryDataStore::Translation.entries.clear

        expect { stage.execute! }.to_not(
          change { InMemoryDataStore::Translation.entries.size }
        )
      end

      it "doesn't update the commit log status (not fully translated yet)" do
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::PULLING)
      end

      it 'updates the status to TRANSLATED if commit contains zero phrases' do
        repo_config.tms.clear
        commit_log.phrase_count = 0
        stage.execute!
        expect(commit_log.status).to eq(PhraseStatus::TRANSLATED)
      end
    end

    context 'with all strings translated in every language' do
      before(:each) do
        repo_config.locales.each do |locale|
          InMemoryDataStore::Phrase.entries.each do |phrase|
            repo_config.tms.auto_translate(locale, phrase)
          end
        end
      end

      context 'with a PENDING status' do
        it 'updates the commit log status to PULLING' do
          stage.execute!
          expect(commit_log.status).to eq(PhraseStatus::PULLING)
        end
      end

      context 'with a PULLING status' do
        before(:each) do
          commit_log.status = PhraseStatus::PULLING
        end

        it 'updates the commit log status to PULLED' do
          stage.execute!
          expect(commit_log.status).to eq(PhraseStatus::PULLED)
        end
      end
    end
  end
end
