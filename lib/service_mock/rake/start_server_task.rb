require 'rake'
require 'rake/tasklib'
require 'service_mock'

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
