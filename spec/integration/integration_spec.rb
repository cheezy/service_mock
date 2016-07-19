require 'spec_helper'
require 'net/http'

describe 'Integration test' do

  # let(:service_mock) {::ServiceMock::Server.new('1.58-standalone')}
  let(:service_mock) {::ServiceMock::Server.new('standalone-2.1.7')}

  it 'starts the server' do
    service_mock.start
    sleep 1
    expect(service_mock.process.alive?).to be true
    service_mock.stop
  end

  it 'stops the server' do
    service_mock.start
    sleep 1
    service_mock.stop
    sleep 1
    expect(service_mock.process.exited?).to be true
  end

  it 'stubs a message' do
    service_mock.start
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
    service_mock.stub(message)
    sleep 1
    uri = URI('http://localhost:8080/get/that')
    result =  Net::HTTP.get(uri)
    expect(result).to eql "There it is\n"

    service_mock.stop
  end

  it 'uses a file and stubs a message' do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/sample.json')
    service_mock.stub_with_file(filename)
    sleep 1
    uri = URI('http://localhost:8080/get/sample')
    result =  Net::HTTP.get(uri)
    expect(result).to eql "This is the sample\n"

    service_mock.stop
  end

  it 'uses an erb file and has to form a message' do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/sample.erb')
    service_mock.stub_with_erb(filename, first: 'Sam', last: 'Smith')
    sleep 1
    uri = URI('http://localhost:8080/get/erb')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Sam Smith</h1>'

    service_mock.stop
  end

  it 'embeds a subtemplate into an erb using render' do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/outer.erb')
    service_mock.stub_with_erb(filename, first: 'Sam', last: 'Smith')
    sleep 1
    uri = URI('http://localhost:8080/get/erb')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Sam Smith</h1>'

    service_mock.stop
  end

  it 'can modify the embedded sutbemplate' do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/parent.erb')
    service_mock.stub_with_erb(filename, {})
    sleep 1
    uri = URI('http://localhost:8080/get/parent')
    result =  Net::HTTP.get(uri)
    expect(result).to eql "This is my message and it contains \"double quotes\""

    service_mock.stop
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
