# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Tms
    module TestTms

      def self.configure(rosette_config, repo_config)
        configurator = Configurator.new(rosette_config, repo_config)
        yield configurator
        Repository.new(configurator)
      end

      class Configurator
        attr_reader :rosette_config, :repo_config, :test_value

        def initialize(rosette_config, repo_config)
          @rosette_config = rosette_config
          @repo_config = repo_config
        end

        def set_test_value(value)
          @test_value = value
        end
      end

      class Repository < Rosette::Tms::Repository
        attr_reader :configurator, :stored_phrases, :translations

        def initialize(configurator)
          @configurator = configurator
          clear
        end

        def store_phrases(phrases, commit_id)
          stored_phrases[commit_id] += phrases
        end

        def store_phrase(phrase, commit_id)
          stored_phrases[commit_id] << phrase
        end

        def lookup_translations(locale, phrases)
          phrases.map do |phrase|
            lookup_translation(locale, phrase)
          end
        end

        def lookup_translation(locale, phrase)
          translations[phrase.index_value][locale.code]
        end

        def checksum_for(locale, commit_id)
          digest = Digest::SHA1.new
          phrases = stored_phrases[commit_id]

          lookup_translations(locale, phrases).each do |trans|
            digest << trans if trans
          end

          digest.hexdigest
        end

        def status(commit_id)
          status = Rosette::Core::TranslationStatus.new(
            stored_phrases[commit_id].size
          )

          locale_counts = Hash.new { |h, k| h[k] = 0 }

          stored_phrases.each_pair do |stored_commit_id, phrases|
            if stored_commit_id == commit_id
              phrases.each do |phrase|
                translations[phrase.index_value].each_pair do |locale_code, _|
                  locale_counts[locale_code] += 1
                end
              end
            end
          end

          locale_counts.each do |locale_code, count|
            status.add_locale_count(locale_code, count)
          end

          status
        end

        def finalize(commit_id)
          # no-op
        end

        # The following methods are not part of Repository interface

        def auto_translate(locale, phrase)
          translations[phrase.index_value][locale.code] = translate(phrase.key)
        end

        def clear
          @stored_phrases = Hash.new { |h, k| h[k] = [] }
          @translations = Hash.new do |phrase_hash, key|
            phrase_hash[key] = {}
          end
        end

        protected

        # the world's quickest and dirtiest pig latin translator
        def translate(str)
          str
            .split(/([ .,!?])/)
            .map do |w|
              w.downcase.sub(/\A([^aeiouAEIOU]*)([aeiouAEIOU][^ ,.!?]*)/) do
                "#{$2}#{$1}ay"
              end
            end
            .join
        end
      end

    end
  end
end
