# encoding: UTF-8

module Rosette
  module Queuing
    module Commits

      # Configuration specific to the "commits" queue that processes commits.
      #
      # @!attribute [r] name
      #   @return [String]
      # @!attribute [r] diff_point
      #   @return [String] the diff point to use when computing phrase diffs.
      #     Defaults to "master". Used only when +phrase_storage_granularity+
      #     is set to [Rosette::Queuing::Commits::PhraseStorageGranularity::BRANCH].
      # @!attribute [r] phrase_storage_granularity
      #   @return [String] determines which set of phrases to push to the TMS.
      #     Must be one of the constant values in
      #     [Rosette::Queuing::Commits::PhraseStorageGranularity]
      #
      # @see Rosette::Queuing::Commits::PhraseStorageGranularity
      class CommitsQueueConfigurator
        DEFAULT_DIFF_POINT = 'master'
        DEFAULT_PHRASE_GRANULARITY = PhraseStorageGranularity::COMMIT

        attr_reader :name, :diff_point, :phrase_storage_granularity

        # Creates a new configurator and sets up a few defaults.
        #
        # @param [String] name The name of the queue.
        # @return [CommitsQueueConfigurator]
        def initialize(name)
          @name = name
          @diff_point = DEFAULT_DIFF_POINT
          @phrase_storage_granularity = DEFAULT_PHRASE_GRANULARITY
        end

        # Sets the phrase storage granularity, i.e. the method used to determine
        # which set of phrases should get uploaded to the TMS.
        #
        # @param [String] granularity One of the constant values in
        #   [Rosette::Queuing::Commits::PhraseStorageGranularity].
        # @return [void]
        def set_phrase_storage_granularity(granularity)
          @phrase_storage_granularity = granularity
        end

        # Sets the diff point to use when computing phrase diffs. Note that this
        # value is only important when +phrase_storage_granularity+ is set to
        # [Rosette::Queuing::Commits::PhraseStorageGranularity::BRANCH].
        #
        # @param [String] new_diff_point The diff point to set.
        # @return [void]
        def set_diff_point(new_diff_point)
          @diff_point = new_diff_point
        end
      end

    end
  end
end
