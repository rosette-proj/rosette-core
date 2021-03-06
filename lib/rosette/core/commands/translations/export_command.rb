# encoding: UTF-8

require 'stringio'
require 'base64'
require 'digest/md5'

module Rosette
  module Core
    module Commands

      # Finds, encodes, and serializes the translations identified by a
      # snapshot of the given git ref or commit id. In other words, this
      # command exports the translations for a git branch or commit. This
      # command also applies any configured pre-processors to the
      # translations before serializing them. As a better visualization,
      # here's the pipeline translations go through when exported:
      #
      # preprocessed -> serialized/encoded -> base 64 encoded (if
      # requested) -> returned
      #
      # @!attribute [r] locale
      #   @return [String] the locale to export translations for.
      # @!attribute [r] serializer
      #   @return [String] the serializer to use when exporting the
      #     translations. Must be recognizable as a serializer id, eg.
      #     'yaml/rails' or 'json/key-value'.
      # @!attribute [r] base_64_encode
      #   @return [Boolean] whether or not the serialized translations
      #     should be returned encoded in base 64.
      # @!attribute [r] encoding
      #   @return [String, Encoding] the encoding translations are
      #     expected to be in. This attribute refers to string encoding
      #     and is distinct from base 64 encoding.
      # @!attribute [r] include_snapshot
      #   @return [Boolean] whether or not the snapshot used to identify
      #     translations is returned alongside the serialized phrases.
      # @!attribute [r] include_checksum
      #   @return [Boolean] whether or not the checksum of translations
      #     is returned alongside the serialized phrases.
      # @!attribute [r] paths
      #   @return [Array<String>] the list of paths to export translations
      #     for. Any translations that belong to phrases that did not come
      #     from a path in this list will not be included in the export.
      # @!attribute [r] fall_back_to_source
      #   @return [Boolean] whether or not to fall back to the source phrase if
      #     a translation doesn't exist.
      #
      # @example
      #   cmd = ExportCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_ref('master')
      #     .set_locale('pt-BR')
      #     .set_serializer('json/key-value')
      #     .set_base_64_encode(true)
      #     .set_encoding(Encoding::UTF_8)
      #     .set_include_snapshot(false)
      #
      #   cmd.execute
      #   # =>
      #   # {
      #   #   payload: "<base 64 encoded string>",
      #   #   encoding: "UTF_8"
      #   #   translation_count: 105,
      #   #   base_64_encoded: true
      #   #   locale: "pt-BR"
      #   # }
      class ExportCommand < GitCommand
        attr_reader :locale, :serializer, :base_64_encode
        attr_reader :encoding, :include_snapshot, :include_checksum
        attr_reader :paths, :fall_back_to_source

        alias_method :fall_back_to_source?, :fall_back_to_source

        include WithRepoName
        include WithRef
        include WithLocale

        include WithSnapshots

        validate :serializer, type: :serializer
        validate :encoding, type: :encoding

        def initialize(*args)
          super
          @paths = []
          @encoding = Encoding::UTF_8
          @base_64_encode = false
          @include_snapshot = false
          @include_checksum = false
          @fall_back_to_source = true
        end

        # Sets the serializer used to export translations. Must be recognizable
        # as a serializer id, eg. 'yaml/rails' or 'json/key-value'.
        #
        # @param [String] serializer The serializer to use.
        # @return [self]
        def set_serializer(serializer)
          @serializer = serializer
          self
        end

        # Sets whether or not the serialized translations should be returned
        # encoded in base 64.
        #
        # @param [Boolean] should_encode To encode or not encode, that is
        #   the question.
        # @return [self]
        def set_base_64_encode(should_encode)
          @base_64_encode = should_encode
          self
        end

        # Sets the encoding translations are expected to be in. Not to be
        # confused with base 64 encoding.
        #
        # @param [String, Encoding] encoding The encoding to use. Can be
        #   either a +String+ or a Ruby +Encoding+, eg. +Encoding::UTF_8+.
        # @return [self]
        def set_encoding(encoding)
          @encoding = encoding
          self
        end

        # Sets whether or not to include the snapshot in the return value.
        #
        # @param [Boolean] should_include_snapshot whether or not to
        #   return the snapshot.
        # @return [self]
        def set_include_snapshot(should_include_snapshot)
          @include_snapshot = should_include_snapshot
          self
        end

        # Sets whether or not to include a checksum of the phrases in the
        # return value.
        #
        # @param [Boolean] should_include_checksum whether or not to include
        #   the checksum.
        # @return [self]
        def set_include_checksum(should_include_checksum)
          @include_checksum = should_include_checksum
          self
        end

        # A list of files or paths to filter translations by. Only translations
        # matching these paths will be included in the export payload.
        def set_paths(paths)
          @paths = Array(paths)
          self
        end

        # If set to true, any untranslated phrases will fall back to the source
        # locale, English for example.
        #
        # @param [Boolean] fall_back Whether or not to fall back to source.
        # @return [self]
        def set_fall_back_to_source(fall_back)
          @fall_back_to_source = fall_back
          self
        end

        # Perform the export.
        #
        # @return [Hash] containing the following attributes:
        #   * +payload+: The serialized +String+ blob of all the translations.
        #   * +encoding+: The encoding of the strings in +payload+.
        #   * +translation_count+: The number of translations in +payload+.
        #   * +base_64_encoded+: A boolean indicating if +payload+ is base
        #     64 encoded.
        #   * +locale+: The locale the translations in +payload+ are written in.
        #   * +snapshot+: The snapshot used to identify the translations in
        def execute
          stream = StringIO.new
          snapshot = take_snapshot(repo_config, commit_id, paths)
          translation_count = 0
          checksum_list = []

          serializer_instance = serializer_config.klass.new(
            stream, locale_obj, encoding
          )

          write_translations_for(snapshot, serializer_instance) do |trans|
            translation_count += 1

            if include_checksum
              checksum_list << "#{trans.phrase.index_value}#{trans.translation}"
            end
          end

          params = {
            payload: encode(stream.string),
            encoding: serializer_instance.encoding.to_s,
            translation_count: translation_count,
            base_64_encoded: base_64_encode,
            locale: locale,
            paths: paths
          }

          if include_snapshot
            params.merge!(snapshot: snapshot)
          end

          if include_checksum
            params.merge!(checksum: checksum_for(checksum_list))
          end

          params
        end

        private

        def write_translations_for(snapshot, serializer_instance)
          each_translation(snapshot) do |trans|
            next unless include_trans?(trans)
            trans = apply_preprocessors(trans, serializer_config)
            yield trans if block_given?

            serializer_instance.write_key_value(
              trans.phrase.index_value, trans.translation
            )
          end

          serializer_instance.flush
        end

        def include_trans?(trans)
          paths.size == 0 || paths.include?(trans.phrase.file)
        end

        def checksum_for(list)
          Digest::MD5.hexdigest(list.sort.join)
        end

        def locale_obj
          @locale_obj ||= repo_config.get_locale(locale)
        end

        def apply_preprocessors(translation, serializer_config)
          serializer_config.preprocessors.inject(translation) do |trans, preprocessor|
            preprocessor.process(trans)
          end
        end

        def encode(string)
          if base_64_encode
            Base64.encode64(string)
          else
            string
          end
        end

        def serializer_config
          @serializer_config ||= repo_config.get_serializer_config(serializer)
        end

        def repo_config
          @repo_config ||= get_repo(repo_name)
        end

        def each_translation(snapshot)
          datastore.phrases_by_commits(repo_name, snapshot) do |phrase|
            text = repo_config.tms.lookup_translation(locale_obj, phrase)
            text ||= phrase.key if fall_back_to_source?

            if text
              yield Translation.new(phrase, locale, text)
            end
          end
        end
      end

    end
  end
end
