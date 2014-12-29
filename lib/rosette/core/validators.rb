# encoding: UTF-8

module Rosette
  module Core

    # Contains validators for validating the parameters of Rosette's commands.
    module Validators
      autoload :Validator,           'rosette/core/validators/validator'
      autoload :CommitValidator,     'rosette/core/validators/commit_validator'
      autoload :RepoValidator,       'rosette/core/validators/repo_validator'
      autoload :SerializerValidator, 'rosette/core/validators/serializer_validator'
      autoload :LocaleValidator,     'rosette/core/validators/locale_validator'
      autoload :EncodingValidator,   'rosette/core/validators/encoding_validator'
    end

  end
end
