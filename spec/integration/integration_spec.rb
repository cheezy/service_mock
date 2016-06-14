require 'spec_helper'
require 'net/http'

describe 'Integration test' do

  # let(:mock) {::ServiceMock::Server.new('1.58-standalone')}
  let(:mock) {::ServiceMock::Server.new('standalone-2.0.10-beta')}

  it 'starts the server' do
    mock.start
    sleep 1
    expect(mock.process.alive?).to be true
    mock.stop
  end

  it 'stops the server' do
    mock.start
    sleep 1
    mock.stop
    sleep 1
    expect(mock.process.exited?).to be true
  end

  it 'stubs a message' do
    mock.start
    sleep 1
    message =
    '
    { "request":
      {
        "url": "/get/that",
        "method": "GET"
      },
      "response":
      {
        "status": 200,
        "body": "There it is\n"
      }
    }
    '
    mock.stub(message)
    sleep 1
    uri = URI('http://localhost:8080/get/that')
    result =  Net::HTTP.get(uri)
    expect(result).to eql "There it is\n"

    mock.stop
  end

  it 'uses a file and stubs a message' do
    mock.start
    sleep 1
    filename = File.expand_path('spec/data/sample.json')
    mock.stub_with_file(filename)
    sleep 1
    uri = URI('http://localhost:8080/get/sample')
    result =  Net::HTTP.get(uri)
    expect(result).to eql "This is the sample\n"

    mock.stop
  end

  it 'uses an erb file and has to form a message' do
    mock.start
    sleep 1
    filename = File.expand_path('spec/data/sample.erb')
    mock.stub_with_erb(filename, first: 'Sam', last: 'Smith')
    sleep 1
    uri = URI('http://localhost:8080/get/erb')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Sam Smith</h1>'

    mock.stop

  end
end

# mock.start do |server|
#   server.https_port = 8081
#   server.record_mappings = true
#   server.proxy_all = 'https://client-test2.schwab.com'
#   server.verbose = true
#   server.inherit_io = true
#   server.wait_for
# end
