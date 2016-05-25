require 'childprocess'
require 'net/http'
require_relative 'command_line_options'

module ServiceMock
  class Server
    include CommandLineOptions

    attr_accessor :inherit_io, :wait_for_process
    attr_reader :wiremock_version, :working_directory

    def initialize(wiremock_version, working_directory='config/mocks')
      @wiremock_version = wiremock_version
      @working_directory = working_directory
    end

    def start
      yield self if block_given?
      start_process
    end

    def stop
      yield self if block_given?
      http.post("/__admin/shutdown", "")
    end

    private

    def start_process
      process = ChildProcess.build(*start_command)
      process.cwd = working_directory
      process.io.inherit! if inherit_io
      process.start
      process.wait if wait_for_process
    end

    def start_command
      ['java', '-jar', "wiremock-#{wiremock_version}.jar"]
    end

    def http
      Net::HTTP.new("localhost", "#{port ? port.to_s : "8080"}")
    end

  end
end
