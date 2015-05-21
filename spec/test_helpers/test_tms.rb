# encoding: UTF-8

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
        attr_reader :configurator, :stored_phrases

        def initialize(configurator)
          @configurator = configurator
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
