require 'rake'
require 'rake/tasklib'
require 'service_mock/server'
require 'service_mock/rake/base_task'

module ServiceMock
  module Rake
    class StartServerTask < ServiceMock::Rake::BaseTask

      def define_task
        desc 'Start the WireMock Process'
        task name do
          server.start
        end
      end

    end
  end
end
