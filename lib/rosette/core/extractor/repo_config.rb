# encoding: UTF-8

module Rosette
  module Core

    # Configuration for a single repository. Instances of {RepoConfig} can
    # be configured to:
    #
    # * Extract phrases (via {#add_extractor}). Phrase extraction means
    #   certain files (that you specify) will be monitored for changes and
    #   processed. For example, you could specify that all files with a .yml
    #   extension be monitored. When Rosette, using git, detects that any of
    #   those files have changed, it will parse the files using an extractor
    #   and store the phrases in the datastore. The Rosette project contains
    #   a number of pre-built extractors. Visit github for a complete list:
    #   https://github.com/rosette-proj. For example, the yaml extractor is
    #   called rosette-extractor-yaml and is available at
    #   https://github.com/rosette-proj/rosette-extractor-yaml. You would
    #   need to add it to your Gemfile and require it before use.
    #
    # * Serialize phrases (via {#add_serializer}). Serializing phrases can be
    #   thought of as the opposite of extracting them. Instead of parsing a
    #   yaml file for example, serialization is the process of turning a
    #   collection of foreign language translations into a big string of yaml
    #   that can be written to a file. Usually serialization happens when
    #   you're ready to export translations from Rosette. In the Rails world
    #   for example, you'd export (or serialize) translations per locale and
    #   store them as files in the config/locales directory. Spanish
    #   translations would be exported to config/locales/es.yml and Japanese
    #   translations to config/locales/ja.yml. The Rosette project contains
    #   a number of pre-built serializers. Visit github for a complete list:
    #   https://github.com/rosette-proj. For example, the yaml serializer is
    #   called rosette-serializer-yaml and is available at
    #   https://github.com/rosette-proj/rosette-serializer-yaml. You would
    #   need to add it to your Gemfile and require it before use.
    #
    # * Pre-process phrases using {SerializerConfig#add_preprocessor}.
    #   Serializers can also pre-process translations (see the example below).
    #   Pre-processing is the concept of modifying a translation just before
    #   it gets serialized. Examples include rosette-preprocessor-normalization,
    #   which is capable of applying Unicode's text normalization algorithm
    #   to translation text. See https://github.com/rosette-proj for a complete
    #   list of pre-processors.
    #
    # * Interact with third-party libraries or services via integrations (see
    #   the {#add_integration} method). Integrations are very general in that
    #   they can be almost anything. For the most part however, integrations
    #   serve as bridges to external APIs or libraries. For example, the
    #   Rosette project currently contains an integration called
    #   rosette-integration-smartling that's responsible for pushing and
    #   pulling translations to/from the Smartling translation platform
    #   (Smartling is a translation management system, or TMS). Since Rosette
    #   is not a TMS (i.e. doesn't provide any GUI for entering translations),
    #   you will need to use a third-party service like Smartling or build
    #   your own TMS solution. Another example is rosette-integration-rollbar.
    #   Rollbar is a third-party error reporting system. The Rollbar
    #   integration not only adds a Rosette-style {ErrorReporter}, it also
    #   hooks into a few places errors might happen, like Rosette::Server's
    #   rack stack.
    #
    # @example
    #   config = RepoConfig.new('my_repo')
    #     .set_path('/path/to/my_repo/.git')
    #     .set_description('My awesome repo')
    #     .set_source_locale('en-US')
    #     .add_locales(%w(pt-BR es-ES fr-FR ja-JP ko-KR))
    #     .add_extractor('yaml/rails') do |ext|
    #       ext.match_file_extension('.yml').and(
    #         ext.match_path('config/locales')
    #       )
    #     end
    #     .add_serializer('rails', 'yaml/rails') do |ser|
    #       ser.add_preprocessor('normalization') do |pre|
    #         pre.set_normalization_form(:nfc)
    #       end
    #     end
    #     .add_integration('smartling') do |sm|
    #       sm.set_api_options(smartling_api_key: 'fakefake', ... )
    #       sm.set_serializer('yaml/rails')
    #     end
    #
    # @!attribute [r] name
    #   @return [String] the name of the repository.
    # @!attribute [r] repo
    #   @return [Repo] a {Repo} instance that can be used to perform git
    #     operations on the local working copy of the associated git
    #     repository.
    # @!attribute [r] locales
    #   @return [Array<Locale>] a list of the locales this repo supports.
    # @!attribute [r] hooks
    #   @return [Hash<Hash<Array<Proc>>>] a hash of callbacks. The outer hash
    #     contains the order while the inner hash contains the action. For
    #     example, if the +hooks+ hash has been configured to do something
    #     after commit, it might look like this:
    #       { after: { commit: [<Proc #0x238d3a>] } }
    # @!attribute [r] description
    #   @return [String] a description of the repository.
    # @!attribute [r] extractor_configs
    #   @return [Array<ExtractorConfig>] a list of the currently configured
    #     extractors.
    # @!attribute [r] serializer_configs
    #   @return [Array<SerializerConfig>] a list of the currently configured
    #     serializers.
    class RepoConfig
      include Integrations::Integratable

      attr_reader :name, :repo, :locales, :hooks, :description
      attr_reader :extractor_configs, :serializer_configs, :translation_path_matchers

      # Creates a new repo config object.
      #
      # @param [String] name The name of the repository. Usually matches the
      #   name of the directory on disk, but that's not required.
      def initialize(name)
        @name = name
        @extractor_configs = []
        @serializer_configs = []
        @locales = []
        @translation_path_matchers = []

        @hooks = Hash.new do |h, key|
          h[key] = Hash.new do |h2, key2|
            h2[key2] = []
          end
        end
      end

      # Sets the path to the repository's .git directory.
      #
      # @param [String] path The path to the repository's .git directory.
      # @return [void]
      def set_path(path)
        @repo = Repo.from_path(path)
      end

      # Sets the description of the repository. This is really just for
      # annotation purposes, the description isn't used by Rosette.
      #
      # @param [String] desc The description text.
      # @return [void]
      def set_description(desc)
        @description = desc
      end

      # Gets the path to the repository's .git directory.
      #
      # @return [String]
      def path
        repo.path if repo
      end

      # Gets the source locale (i.e. the locale all the source files are in).
      # Defaults to en-US.
      #
      # @return [Locale] the source locale.
      def source_locale
        @source_locale ||= Locale.parse('en-US', Locale::DEFAULT_FORMAT)
      end

      # Sets the source locale.
      #
      # @param [String] code The locale code.
      # @param [Symbol] format The format +locale+ is in.
      # @return [void]
      def set_source_locale(code, format = Locale::DEFAULT_FORMAT)
        @source_locale = Locale.parse(code, format)
      end

      # Adds an extractor to this repo.
      #
      # @param [String] extractor_id The id of the extractor you'd like to add.
      # @yield [config] yields the extractor config
      # @yieldparam config [ExtractorConfig]
      # @return [void]
      def add_extractor(extractor_id)
        klass = ExtractorId.resolve(extractor_id)
        extractor_configs << ExtractorConfig.new(extractor_id, klass).tap do |config|
          yield config if block_given?
        end
      end

      # Adds a serializer to this repo.
      #
      # @param [String] name A semantic name for this serializer. Means nothing
      #   to Rosette, simply a way for you to label the serializer.
      # @param [Hash] options A hash of options containing the following entries:
      #   * +format+: The id of the serializer, eg. "yaml/rails".
      # @yield [config] yields the serializer config
      # @yieldparam config [SerializerConfig]
      # @return [void]
      def add_serializer(name, options = {})
        serializer_id = options[:format]
        klass = SerializerId.resolve(serializer_id)
        serializer_configs << SerializerConfig.new(name, klass, serializer_id).tap do |config|
          yield config if block_given?
        end
      end

      # Adds a locale to the list of locales this repo supports.
      #
      # @param [String] locale_code The locale you'd like to add.
      # @param [Symbol] format The format of +locale_code+.
      # @return [void]
      def add_locale(locale_code, format = Locale::DEFAULT_FORMAT)
        add_locales(locale_code)
      end

      # Adds multiple locales to the list of locales this repo supports.
      #
      # @param [Array<String>] locale_codes The list of locales to add.
      # @param [Symbol] format The format of +locale_codes+.
      # @return [void]
      def add_locales(locale_codes, format = Locale::DEFAULT_FORMAT)
        @locales += Array(locale_codes).map do |locale_code|
          Locale.parse(locale_code, format)
        end
      end

      # Adds an after hook. You should pass a block to this method. The
      # block will be executed when the hook fires.
      #
      # @param [Symbol] action The action to hook. Currently the only
      #   supported action is +:commit+.
      # @return [void]
      def after(action, &block)
        hooks[:after][action] << block
      end

      # Retrieves the extractor configs that match the given path.
      #
      # @param [String] path The path to match.
      # @return [Array<ExtractorConfig>] a list of the extractor configs that
      #   were found to match +path+.
      def get_extractor_configs(path)
        extractor_configs.select do |config|
          config.matches?(path)
        end
      end

      # Retrieves the extractor config by either name or extractor id.
      #
      # @param [String] name_or_id The name or extractor id.
      # @return [nil, ExtractorConfig] the first matching extractor config.
      #   Potentially returns +nil+ if no matching extractor config can be
      #   found.
      def get_extractor_config(extractor_id)
        extractor_configs.find do |config|
          config.extractor_id == extractor_id
        end
      end

      # Retrieves the serializer config by either name or serializer id.
      #
      # @param [String] name_or_id The name or serializer id.
      # @return [nil, SerializerConfig] the first matching serializer config.
      #   Potentially returns +nil+ if no matching serializer config can be
      #   found.
      def get_serializer_config(name_or_id)
        found = serializer_configs.find do |config|
          config.name == name_or_id
        end

        found || serializer_configs.find do |config|
          config.serializer_id == name_or_id
        end
      end

      # Retrieves the locale object by locale code.
      #
      # @param [String] code The locale code to look for.
      # @param [Symbol] format The locale format +code+ is in.
      # @return [nil, Locale] The locale who's code matches +code+. Potentially
      #   returns +nil+ if the locale can't be found.
      def get_locale(code, format = Locale::DEFAULT_FORMAT)
        locale_to_find = Locale.parse(code, format)
        locales.find { |locale| locale == locale_to_find }
      end

      def add_translation_path_matcher
        translation_path_matchers << TranslationsPathConfig.new.tap do |tpconfig|
          yield tpconfig if block_given?
        end
      end

      def get_translation_path_matcher(path)
        translation_path_matchers.detect do |config|
          config.matches?(path)
        end
      end
    end
  end
end
