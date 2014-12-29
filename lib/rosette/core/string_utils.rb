# encoding: UTF-8

module Rosette
  module Core

    # General-purpose string manipulation utilities.
    class StringUtils
      class << self
        # Converts a snake_cased string into a CamelCased one.
        #
        # @example
        #   StringUtils.camelize('foo_bar')  # => "FooBar"
        #
        # @param [String] str The snake_cased string to convert.
        # @return [String]
        def camelize(str)
          str.gsub(/(^\w|[-_]\w)/) { $1[-1].upcase }
        end
      end
    end

  end
end
