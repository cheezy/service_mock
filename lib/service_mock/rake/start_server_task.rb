require 'rake'
require 'rake/tasklib'
require 'service_mock/server'

module ServiceMock
  module Rake
    class StartServerTask < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      attr_reader :name, :wiremock_version, :working_directory, :server

      def initialize(name, wiremock_version, working_directory='config/mocks')
        @name = name
        @wiremock_version = wiremock_version
        @working_directory = working_directory
        @server ||= ::ServiceMock::Server.new(wiremock_version, working_directory)
        yield server if block_given?
        define_task
      end

      private

      def define_task
        desc 'Start the WireMock Process'
        task name do
          server.start
        end
      end

    end
  end
end
