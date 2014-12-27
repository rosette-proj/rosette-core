# encoding: UTF-8

module Rosette
  module Core
    module Commands

      # Mixin that handles configuration and validation of a locale code.
      # Meant to be mixed into the classes in {Rosette::Core::Commands}.
      #
      # @example
      #   class MyCommand < Rosette::Core::Commands::Command
      #     include WithRepoName
      #     include WithLocale
      #   end
      #
      #   cmd = MyCommand.new(configuration)
      #     .set_repo_name('my_repo')
      #     .set_locale('ja-JP')
      #
      #   cmd.locale    # => 'ja-JP'
      #   cmd.valid?    # => true
      #
      #   cmd.set_locale('foobar')
      #   cmd.valid?    # => false
      #   cmd.messages  # => { locale: ["Repo 'my_repo' doesn't support the 'foobar' locale"] }
      module WithLocale
        attr_reader :locale

        def set_locale(locale_code)
          @locale = locale_code
          self
        end

        protected

        def self.included(base)
          base.validate :locale, type: :locale
        end
      end

    end
  end
end
