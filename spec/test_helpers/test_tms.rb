# encoding: UTF-8

module Rosette
  module Tms
    module TestTms

      def self.configure(rosette_config, repo_config)
        Repository.new.tap { |repo| yield repo }
      end

      class Repository < Rosette::Tms::Repository
        attr_reader :stored_phrases

        def initialize
          @stored_phrases = Hash.new { |h, k| h[k] = [] }
        end

        def store_phrases(phrases, commit_id)
          stored_phrases[commit_id] += phrases
        end

        def store_phrase(phrase, commit_id)
          stored_phrases[commit_id] << phrase
        end
      end

    end
  end
end
