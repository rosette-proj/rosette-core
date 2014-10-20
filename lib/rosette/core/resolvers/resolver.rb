# encoding: UTF-8

module Rosette
  module Core

    class Resolver
      class << self

        def resolve(id, namespace)
          klass = case id
            when Class
              id
            when String
              parse_id(id, namespace)
          end

          unless klass
            raise ArgumentError, "#{id} could not be found - have you required it?"
          end

          klass
        end

        private

        def parse_id(id, namespace)
          find_const(
            const_candidates(
              id.split('/').map do |segment|
                StringUtils.camelize(segment)
              end
            ), namespace
          )
        end

        # Appends the suffix to each segment one at a time and returns intermediate
        # arrays of segments. For example, if given ['Json', 'KeyValue'] and a suffix
        # of 'Serializer', this method would return:
        # [['Json', 'KeyValue'], ['Json', 'KeyValueSerializer'], ['JsonSerializer', 'KeyValueSerializer']]
        def const_candidates(segments)
          [segments] + segments.map.with_index do |segment, idx|
            candidate = segments[0...(segments.size - (idx + 1))]
            candidate + segments[(segments.size - (idx + 1))..-1].map do |sub_seg|
              "#{sub_seg}#{suffix}"
            end
          end
        end

        def suffix
          raise NotImplementedError, "#{__method__} must be defined in derived classes"
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
