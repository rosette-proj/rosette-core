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
        attr_reader :paths

        include WithRepoName
        include WithRef
        include WithLocale

        include WithSnapshots

        validate :serializer, type: :serializer
        validate :encoding, type: :encoding

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
          @paths = paths
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
        #     +payload+. Not included if +base_64_encode+ is +false+.
        def execute
          stream = StringIO.new
          repo_config = get_repo(repo_name)
          serializer_config = get_serializer_config(repo_config)
          serializer_instance = serializer_config.klass.new(stream, locale_obj, encoding)
          snapshot = take_snapshot(repo_config, commit_id, Array(paths))
          translation_count = 0
          checksum_list = []

          each_translation(repo_config, snapshot) do |trans|
            trans = apply_preprocessors(trans, serializer_config)

            serializer_instance.write_key_value(
              trans.phrase.index_value, trans.translation
            )

            translation_count += 1

            if include_checksum
              checksum_list << "#{trans.phrase.index_value}#{trans.translation}"
            end
          end

          serializer_instance.flush

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

        def checksum_for(list)
          Digest::MD5.hexdigest(list.sort.join)
        end

        def locale_obj
          @locale_obj ||= get_repo(repo_name).get_locale(locale)
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

        def get_serializer_config(repo_config)
          repo_config.get_serializer_config(serializer)
        end

        def each_translation(repo_config, snapshot)
          datastore.translations_by_commits(repo_name, locale, snapshot) do |trans|
            yield trans
          end
        end
      end

    end
  end
end
