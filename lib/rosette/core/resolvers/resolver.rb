# encoding: UTF-8

module Rosette
  module Core

    # Base class for Rosette's id resolvers that can look up a class constant
    # given a namespaced id (string separated by forward slashes). For example,
    # the extractor id "yaml/rails" resolves to
    # +Rosette::Extractors::YamlExtractor::RailsExtractor+.
    #
    # @example
    #   class MyResolver < Resolver
    #     def resolve(id, namespace = MyNamespace::Foo)
    #       super
    #     end
    #
    #     private
    #
    #     # Must be defined by classes that inherit from Resolver.
    #     def suffix
    #       'Stuff'
    #     end
    #   end
    #
    #   module MyNamespace
    #     module Foo
    #       module BarStuff
    #         class BazStuff
    #           ...
    #         end
    #       end
    #     end
    #   end
    #
    #   MyResolver.resolve('bar/baz')  # => MyNamespace::Foo::BarStuff::BazStuff
    class Resolver
      class << self

        # Parses and identifies the class constant for the given id.
        #
        # @param [Class, String] id When given a class, returns the class. When
        #   given a string, parses and identifies the corresponding class
        #   constant in +namespace+.
        # @param [Class] namespace The namespace to look in.
        # @return [Class] The identified class constant.
        def resolve(id, namespace)
          klass = case id
            when Class
              id
            when String
              lookup(id, namespace)
          end

          unless klass
            raise ArgumentError, "#{id} could not be found - have you required it?"
          end

          klass
        end

        # Splits an id into parts.
        #
        # @param [String] id The id to parse.
        # @return [Array<String>] A list of id parts.
        def parse_id(id)
          id.split('/')
        end

        private

        def lookup(id, namespace)
          find_const(
            const_candidates(
              parse_id(id).map do |segment|
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
              if const && const.constants.include?(segment.to_sym)
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
