require 'spec_helper'
require 'net/http'
require 'service_mock/rake/start_server_task'

describe 'Rake Task test' do

  #let(:mock) {ServiceMock::Server.new('1.57-standalone')}
  let(:mock) { ServiceMock::Server.new('standalone-2.0.10-beta') }
  let(:task) { ::ServiceMock::Rake::StartServerTask }

  it 'starts the server process' do
    rake_task = task.new(:start_server, 'standalone-2.0.10-beta')
    ::Rake::Task[:start_server].execute
    sleep 1
    expect(rake_task.server.process.alive?).to be true
    mock.stop
  end
end
