require 'spec_helper'
require 'net/http'

describe 'Integration test' do

  #let(:mock) {ServiceMock::Server.new('1.57-standalone')}
  let(:mock) {ServiceMock::Server.new('standalone-2.0.10-beta')}
  let(:http) {Net::HTTP.new('localhost', '8080')}

  it 'starts the server' do
    mock.start
    sleep 2
    expect(mock.process.alive?).to be true
    mock.stop
  end

  it 'stops the server' do
    mock.start
    sleep 2
    mock.stop
    sleep 1
    expect(mock.process.exited?).to be true
  end

  it 'stubs a message' do
    mock.start
    sleep 2
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
end

# mock.start do |server|
#   server.https_port = 8081
#   server.record_mappings = true
#   server.proxy_all = 'https://client-test2.schwab.com'
#   server.verbose = true
#   server.inherit_io = true
#   # server.wait_for_process = true
# end

# sleep 5
#
# message =
# '
# { "request":
#   {
#     "url": "/get/that",
#     "method": "GET"
#   },
#   "response":
#   {
#     "status": 200,
#     "body": "There it is\n"
#   }
# }
# '
#
# mock.stub(message)

# mock.save

# mock.stop