# encoding: UTF-8

module Rosette
  module Core

    class Ref
      DELIMITER = '/'

      class << self
        def parse(ref_name)
          chunks = ref_name.split(DELIMITER)

          if chunks.first == 'refs'
            create_from(chunks[1..-1])
          end
        end

        def inherited(subclass)
          descendants << subclass
        end

        protected

        def create_from(chunks)
          descendants.each do |descendant|
            if ref = descendant.create_from(chunks)
              return ref
            end
          end
        end

        def descendants
          @descendants ||= []
        end
      end

      attr_reader :name

      def remote?
        type == :remote
      end

      def head?
        type == :head
      end

      def tag?
        type == :tag
      end
    end

    class Remote < Ref
      def self.create_from(chunks)
        if chunks.first == 'remotes'
          new(chunks[1], chunks[2..-1].join(DELIMITER))
        end
      end

      attr_reader :remote

      def initialize(remote, name)
        @remote = remote
        @name = name
      end

      def type
        :remote
      end

      def to_s
        "refs/remotes/#{remote}/#{name}"
      end
    end

    class Head < Ref
      def self.create_from(chunks)
        if chunks.first == 'heads'
          new(chunks[1..-1].join(DELIMITER))
        end
      end

      def initialize(name)
        @name = name
      end

      def type
        :head
      end

      def to_s
        "refs/heads/#{name}"
      end
    end

    class Tag < Ref
      def self.create_from(chunks)
        if chunks.first == 'tags'
          new(chunks[1..-1].join(DELIMITER))
        end
      end

      def initialize(name)
        @name = name
      end

      def type
        :tag
      end

      def to_s
        "refs/tags/#{name}"
      end
    end

  end
end
