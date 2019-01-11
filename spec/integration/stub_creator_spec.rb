require 'spec_helper'

describe ::ServiceMock::StubCreator do

  let(:service_mock) { ServiceMock::Server.new('standalone-2.20.0') }

  it 'should create stubs' do
    service_mock.start
    sleep 1

    stub_creator = ::ServiceMock::StubCreator.new(service_mock)
    stub_creator.create_stubs_with('example.yml')
    sleep 1
    uri = URI('http://localhost:8080/get/sample')
    result =  Net::HTTP.get(uri)
    expect(result).to eql '<h1>Hello Donald Duck</h1>'

    service_mock.stop
  end

  it 'should not create stubs when it is disabled' do
    ::ServiceMock.disable_stubs = true
    service_mock.start
    sleep 1

    stub_creator = ::ServiceMock::StubCreator.new(service_mock)
    stub_creator.create_stubs_with('example.yml')
    sleep 1
    uri = URI('http://localhost:8080/get/sample')
    result =  Net::HTTP.get(uri)
    expect(result).to include 'No response could be served'

    service_mock.stop
    ::ServiceMock.disable_stubs = false
  end
end