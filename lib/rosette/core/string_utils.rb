# encoding: UTF-8

module Rosette
  module Core
    class StringUtils
      class << self

        def camelize(str)
          str.gsub(/(^\w|[-_]\w)/) { $1[-1].upcase }
        end

      end
    end
  end
end
