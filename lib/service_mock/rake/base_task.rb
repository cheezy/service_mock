require 'rake'
require 'rake/tasklib'
require 'service_mock/server'

module ServiceMock
  module Rake
    class BaseTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      attr_reader :name, :server

      def initialize(name, wiremock_version, working_directory='config/mocks')
        @name = name
        @server = ::ServiceMock::Server.new(wiremock_version, working_directory)
        yield server if block_given?
        define_task
      end

    end
  end
end
