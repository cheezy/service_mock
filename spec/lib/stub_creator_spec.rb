require 'spec_helper'

describe ::ServiceMock::StubCreator do

  let(:server) { ::ServiceMock::Server.new('123') }
  let(:stub_creator) { ::ServiceMock::StubCreator.new(server) }
  let(:file) { double('file').as_null_object }
  let(:filename) { File.expand_path('config/mocks/stubs/data/file') }

  before do
    allow(File).to receive(:open).with(filename, 'rb').and_yield(file)
    allow(server).to receive(:stub_with_erb)
  end

  describe 'initialization' do

    it 'requires a service_mock instance' do
      stub_creator = ::ServiceMock::StubCreator.new(server)
      expect(stub_creator.server).to eql server
    end

    it 'validates that it is an actual server instance' do
      expect {
        ::ServiceMock::StubCreator.new('blah')
      }.to raise_error(RuntimeError, "You must provide an instance of ::ServiceMock::Server!\n")
    end

  end

  describe 'reading the data file and setting up the stubs' do

    it 'reads the provided file and creates a Hash' do
      expect(File).to receive(:open).with(filename, 'rb').and_yield(file)
      expect(file).to receive(:read).and_return("service.xml:\n  key: value\n")
      stub_creator.create_stubs_with('file')
      expect(stub_creator.data).to eql({'service.xml' => {'key' => 'value'}})
    end

    it 'stubs a service call for each entry in the data file' do
      data =
          "" "
      service1.xml:
        key1: value1

      service2.xml:
        key2: value2
      " ""
      template_dir = File.expand_path('config/mocks/stubs/templates/')
      allow(file).to receive(:read).and_return(data)
      expect(server).to receive(:stub_with_erb).with("#{template_dir}/service1.xml", {'key1' => 'value1'})
      expect(server).to receive(:stub_with_erb).with("#{template_dir}/service2.xml", {'key2' => 'value2'})
      stub_creator.create_stubs_with('file')
    end

  end

  describe 'merging data when stubbing' do
    it 'adds values from the provided hash' do
      data =
          "" "
      service1.xml:
        key1: value1
          " ""
      template_dir = File.expand_path('config/mocks/stubs/templates/')
      allow(file).to receive(:read).and_return(data)
      expect(server).to receive(:stub_with_erb).
          with("#{template_dir}/service1.xml",
               {'key1' => 'value1', 'key2' => 'value2'})
      stub_creator.create_stubs_with('file', 'service1.xml' => {'key2' => 'value2'})
    end

    it 'updates values from the provided hash' do
      data =
          "" "
      service1.xml:
        key1: original
          " ""
      template_dir = File.expand_path('config/mocks/stubs/templates/')
      allow(file).to receive(:read).and_return(data)
      expect(server).to receive(:stub_with_erb).
          with("#{template_dir}/service1.xml", {'key1' => 'updated'})
      stub_creator.create_stubs_with('file', 'service1.xml' => {'key1' => 'updated'})
    end
  end

end