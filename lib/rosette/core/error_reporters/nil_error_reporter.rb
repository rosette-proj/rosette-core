# encoding: UTF-8

module Rosette
  module Core

    class NilErrorReporter
      def self.instance
        @instance ||= new
      end

      def report_error(error); end
      def report_warning(error); end
    end

  end
end
