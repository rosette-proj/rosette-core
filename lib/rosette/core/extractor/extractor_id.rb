# encoding: UTF-8

module Rosette
  module Core

    class ExtractorId
      class << self

        def resolve(extractor_id, namespace = Rosette::Extractors)
          klass = case extractor_id
            when Class
              extractor_id
            when String
              parse_id(extractor_id, namespace)
          end

          unless klass
            raise ArgumentError, "#{extractor_id} could not be found - have you required it?"
          end

          klass
        end

        private

        def parse_id(extractor_id, namespace)
          find_const(
            const_candidates(
              extractor_id.split('/').map do |segment|
                StringUtils.camelize(segment)
              end
            ), namespace
          )
        end

        # Appends 'Extractor' to each segment one at a time and returns intermediate
        # arrays of segments. For example, if given ['Ruby', 'FastGettext'],
        # this method would return:
        # [['Ruby', 'FastGettext'], ['Ruby', 'FastGettextExtractor'], ['RubyExtractor', 'FastGettextExtractor']]
        def const_candidates(segments)
          [segments] + segments.map.with_index do |segment, idx|
            candidate = segments[0...(segments.size - (idx + 1))]
            candidate + segments[(segments.size - (idx + 1))..-1].map do |sub_seg|
              "#{sub_seg}Extractor"
            end
          end
        end

        def find_const(candidates, namespace)
          candidates.each do |segments|
            found_const = segments.inject(namespace) do |const, segment|
              if const && const.const_defined?(segment)
                const.const_get(segment)
              end
            end

            return found_const if found_const
          end
          nil
        end

      end
    end

  end
end