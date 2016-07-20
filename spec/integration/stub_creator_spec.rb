require 'spec_helper'

describe ::ServiceMock::StubCreator do
  it 'should create stubs' do
    service_mock = ::ServiceMock::Server.new('standalone-2.1.7')
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
end