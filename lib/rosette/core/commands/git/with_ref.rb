# encoding: UTF-8

require 'thread'

module Rosette
  module Core
    module Commands

      module WithRef
        attr_reader :commit_str

        REV_COMMIT_MUTEX = Mutex.new

        def self.included(base)
          if base.respond_to?(:validate)
            base.validate :commit_str, type: :commit
          end
        end

        def set_ref(ref_str)
          @commit_str = ref_str
          self
        end

        def set_commit_id(commit_id)
          @commit_str = commit_id
          self
        end

        def commit_id
          @commit_id ||= begin
            REV_COMMIT_MUTEX.synchronize do
              get_repo(repo_name)
                .repo.get_rev_commit(@commit_str)
                .getId.name
            end
          end
        end
      end

    end
  end
end
