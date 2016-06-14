require 'rake'
require 'rake/tasklib'
require 'service_mock/server'
require 'service_mock/rake/base_task'

module ServiceMock
  module Rake
    class StopServerTask < ServiceMock::Rake::BaseTask

      def define_task
        desc 'Stop the WireMock Process'
        task name do
          server.stop
        end
      end
    end
  end
end
