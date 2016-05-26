require 'spec_helper'

describe 'Integration test' do

  #let(:mock) {ServiceMock::Server.new('1.57-standalone')}
  let(:mock) {ServiceMock::Server.new('standalone-2.0.10-beta')}

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