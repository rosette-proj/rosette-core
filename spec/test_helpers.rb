# encoding: UTF-8

require 'spec/test_helpers/test_extractor'
require 'spec/test_helpers/test_serializer'
require 'spec/test_helpers/test_integration'
require 'spec/test_helpers/test_data_store'

module TestHelpers
  autoload :Fixtures, 'spec/test_helpers/fixtures'

  class << self

    def fixture_path
      @fixture_path ||= File.join(
        File.expand_path('./', File.dirname(__FILE__)), 'fixtures/repos'
      )
    end

    def fixture_bin_path
      File.join(fixture_path, 'bin')
    end

    def fixture_lib_path
      File.join(fixture_path, 'lib')
    end

  end
end
