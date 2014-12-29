# encoding: UTF-8

module Rosette
  module Preprocessors

    # Errors that can be raised during pre-processing.
    module Errors
      # Raised if a preprocessor doesn't know how to process the object given
      # to it.
      class UnsupportedObjectError < StandardError; end
    end

  end
end
