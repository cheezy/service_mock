module ServiceMock
  module CommandLineOptions
    attr_accessor :port, :https_port

    def port_command
      ['--port', port.to_s]
    end

    def https_port_command
      ['--https-port', https_port.to_s]
    end
  end
end