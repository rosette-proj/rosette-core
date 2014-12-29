# encoding: UTF-8

require 'digest/sha1'

module Rosette
  module Core

    # Namespace for all Rosette commands.
    module Commands

      autoload :Errors,                        'rosette/core/commands/errors'

      autoload :CommitCommand,                 'rosette/core/commands/git/commit_command'
      autoload :DiffBaseCommand,               'rosette/core/commands/git/diff_base_command'
      autoload :DiffCommand,                   'rosette/core/commands/git/diff_command'
      autoload :ShowCommand,                   'rosette/core/commands/git/show_command'
      autoload :StatusCommand,                 'rosette/core/commands/git/status_command'
      autoload :FetchCommand,                  'rosette/core/commands/git/fetch_command'
      autoload :SnapshotCommand,               'rosette/core/commands/git/snapshot_command'
      autoload :RepoSnapshotCommand,           'rosette/core/commands/git/repo_snapshot_command'

      autoload :AddOrUpdateTranslationCommand, 'rosette/core/commands/translations/add_or_update_translation_command'
      autoload :ExportCommand,                 'rosette/core/commands/translations/export_command'

      autoload :WithRepoName,                  'rosette/core/commands/git/with_repo_name'
      autoload :WithRef,                       'rosette/core/commands/git/with_ref'
      autoload :WithNonMergeRef,               'rosette/core/commands/git/with_non_merge_ref'
      autoload :WithSnapshots,                 'rosette/core/commands/git/with_snapshots'
      autoload :DiffEntry,                     'rosette/core/commands/git/diff_entry'
      autoload :WithLocale,                    'rosette/core/commands/translations/with_locale'

      # Base class for all Rosette commands.
      #
      # @!attribute [r] configuration
      #   @return [Configurator] Rosette configuration.
      class Command
        attr_reader :configuration

        class << self
          # Validates a single field.
          #
          # @param [Symbol] field The field to validate.
          # @param [Hash] validator_hash The hash of options for this
          #   validation. For now, should just contain +:type+ which contains
          #   to a symbol corresponding to the type of validator to use.
          # @return [void]
          def validate(field, validator_hash)
            validators[field] << instantiate_validator(validator_hash)
          end

          # A hash of all the currently configured validators.
          #
          # @return [Hash<Symbol, Array<Validator>>] The hash of fields to
          #   valdiator instances.
          def validators
            @validators ||= Hash.new { |hash, key| hash[key] = [] }
          end

          private

          def instantiate_validator(validator_hash)
            validator_type = validator_hash.fetch(:type)
            validator_class_for(validator_type).new(validator_hash)
          end

          def validator_class_for(validator_type)
            klass = "#{Rosette::Core::StringUtils.camelize(validator_type.to_s)}Validator"
            if Rosette::Core::Validators.const_defined?(klass)
              Rosette::Core::Validators.const_get(klass)
            else
              raise TypeError, "couldn't find #{validator_type} validator"
            end
          end
        end

        # Creates a new command instance.
        #
        # @param [Configurator] configuration The Rosette configuration to use.
        def initialize(configuration)
          @configuration = configuration
        end

        # Gets the hash of current error messages.
        #
        # @return [Hash<Symbol, Array<String>>] The hash of current messages.
        #   The hash's keys are field names and the values are arrays of error
        #   messages for that field.
        def messages
          @messages ||= {}
        end

        # Returns true if the command's validators all pass, false otherwise.
        #
        # @raise [NotImplementedError]
        def valid?
          raise NotImplementedError, 'please use a Command subclass.'
        end

        protected

        def datastore
          configuration.datastore
        end

        def path_digest(paths)
          Digest::MD5.hexdigest(paths.join)
        end
      end

      # Base class for all of Rosette's git-based commands.
      class GitCommand < Command
        # Returns true if the command's validators all pass, false otherwise.
        # After this method is finished executing, the +messages+ hash will
        # have been populated with error messages per field.
        #
        # @return [Boolean]
        def valid?
          self.class.validators.all? do |name, validators|
            validators.all? do |validator|
              valid = validator.valid?(send(name), repo_name, configuration)
              messages[name] = validator.messages unless valid
              valid
            end
          end
        end

        protected

        def get_repo(name)
          configuration.get_repo(name)
        end
      end

    end
  end
end
