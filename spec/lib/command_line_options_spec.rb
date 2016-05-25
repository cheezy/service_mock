require 'spec_helper'

describe ServiceMock::CommandLineOptions do

  let(:clo) {ServiceMock::Server.new('123')}

  it 'provides a port option' do
    clo.port = 123
    expect(clo.port_command).to eql ['--port', '123']
  end

  it 'provides a https port option' do
    clo.https_port = 123
    expect(clo.https_port_command).to eql ['--https-port', '123']
  end
end