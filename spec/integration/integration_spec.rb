require 'spec_helper'
require 'net/http'

describe 'Integration test' do

  let(:service_mock) {::ServiceMock::Server.new('standalone-2.5.0')}

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

  it 'can modify the embedded subtemplate' do
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

  it 'does not send a stub when it is disabled' do
    ::ServiceMock.disable_stubs = true
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/parent.erb')
    service_mock.stub_with_erb(filename, {})
    sleep 1
    uri = URI('http://localhost:8080/get/parent')
    result =  Net::HTTP.get(uri)
    expect(result).to include "Not Found"

    service_mock.stop
    ::ServiceMock.disable_stubs = false
  end

  it 'uses the default value when value not present' do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/default_value.erb')
    service_mock.stub_with_erb(filename, {})
    sleep 1
    uri = URI('http://localhost:8080/get/erb')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Fred</h1>'

    service_mock.stop
  end

  it "overrides the default value with the provided value" do
    service_mock.start
    sleep 1
    filename = File.expand_path('spec/data/default_value.erb')
    service_mock.stub_with_erb(filename, name: 'Tom')
    sleep 1
    uri = URI('http://localhost:8080/get/erb')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Tom</h1>'

    service_mock.stop
  end
end

