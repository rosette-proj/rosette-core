# encoding: UTF-8

module Rosette
  module Serializers

    module Test
      class TestSerializer < Rosette::Serializers::Serializer
        def write_translation(trans)
          key = sanitize(trans.phrase.key)
          trans = sanitize(trans.translation)
          stream.write("#{key} = #{trans}\n")
        end

        def close
        end

        private

        def sanitize(str)
          str.gsub(%q("), %q(\"))
        end
      end
    end

  end
end
