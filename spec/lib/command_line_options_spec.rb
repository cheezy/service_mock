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

  it 'provides a verbose option' do
    clo.verbose = true
    expect(clo.verbose_command).to eql ['--verbose']
  end

  it 'provides a root_dir option' do
    clo.root_dir = 'foo/bar'
    expect(clo.root_dir_command).to eql ['--root-dir', 'foo/bar']
  end

  it 'provides a record_mappings option' do
    clo.record_mappings = true
    expect(clo.record_mappings_command).to eql ['--record-mappings']
  end

  it 'provides a proxy_all option' do
    clo.proxy_all = 'http://proxy.ca'
    expect(clo.proxy_all_command).to eql ['--proxy-all="http://proxy.ca"']
  end
end