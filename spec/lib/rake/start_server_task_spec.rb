require 'spec_helper'
require 'service_mock/rake/start_server_task'

describe ServiceMock::Rake::StartServerTask do

  let(:raketask) { ::ServiceMock::Rake::StartServerTask }
  let(:server) { double('server').as_null_object }

  it 'sets the description on the task' do
    raketask.new(:start_server, '123')
    expect(Rake.application.last_description).to eql('Start the WireMock Process')
  end

  it 'creates the task with the appropriate name' do
    expect(Rake::Task).to receive(:define_task).with(:start_server)
    raketask.new(:start_server, '123')
  end

  it 'sets the wiremock version' do
    rake_task = raketask.new(:start_server, '1234')
    expect(rake_task.server.wiremock_version).to eql('1234')
  end

  it 'passes block values to the server' do
    rake_task = raketask.new(:start_server, '123') do |task|
      task.verbose = true
      task.port = 8080
    end
    expect(rake_task.server.verbose).to be true
    expect(rake_task.server.port).to eql 8080
  end

  it 'starts the server' do
    expect(::ServiceMock::Server).to receive(:new).and_return server
    expect(server).to receive(:start)
    raketask.new(:start_server, '123') do |task|
      task.port = 8080
    end
    ::Rake::Task[:start_server].execute
  end
end