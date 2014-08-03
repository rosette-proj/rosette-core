# encoding: UTF-8

module Rosette
  module Core

    class ExtractorId
      class << self

        def resolve(extractor_id)
          klass = case extractor_id
            when Class
              extractor_id
            when String
              parse_id(extractor_id)
          end

          unless klass
            raise ArgumentError, "#{extractor_id} could not be found - have you required it?"
          end

          klass
        end

        private

        def parse_id(extractor_id)
          find_const(
            const_candidates(
              extractor_id.split('/').map do |segment|
                StringUtils.camelize(segment)
              end
            )
          )
        end

        def const_candidates(segments)
          [segments] + segments.map.with_index do |segment, idx|
            candidate = segments[0...(segments.size - (idx + 1))]
            candidate + segments[(segments.size - (idx + 1))..-1].map do |sub_seg|
              "#{sub_seg}Extractor"
            end
          end
        end

        def find_const(candidates)
          candidates.each do |segments|
            found_const = segments.inject(Rosette::Extractors) do |const, segment|
              if const && const.const_defined?(segment)
                const.const_get(segment)
              end
            end

            return found_const if found_const
          end
        end

      end
    end

  end
end