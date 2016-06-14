require 'spec_helper'

describe ::ServiceMock::Server do

  let(:mock) {::ServiceMock::Server.new('123')}
  let(:http)  {double('http').as_null_object}

  before do
    allow(Net::HTTP).to receive(:new).with('localhost', '8080').and_return http
  end


  describe 'initialization' do
    it 'requires the version of wiremock to use' do
      mock = ::ServiceMock::Server.new('123')
      expect(mock.wiremock_version).to eql '123'
    end

    it 'requires the wiremock working directory' do
      mock = ::ServiceMock::Server.new('123', '/working/directory')
      expect(mock.working_directory).to eql '/working/directory'
    end

    it 'defaults the working directory to "config/mocks"' do
      mock = ::ServiceMock::Server.new('123')
      expect(mock.working_directory).to eql 'config/mocks'
    end
  end

  require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

  describe 'starting the server' do
    let(:child) {double('child').as_null_object}

    before do
      allow(ChildProcess).to receive(:build).and_return(child)
    end

    it 'starts the mock in the proper directory' do
      expect(ChildProcess).to receive(:build).with('java', '-jar', 'wiremock-123.jar').and_return(child)
      expect(child).to receive(:cwd=).with('config/mocks')
      expect(child).to receive(:start)
      mock.start
    end

    it 'allows the process to inherit the io by setting value in block' do
      expect(child).to receive(:io).and_return(child)
      expect(child).to receive(:inherit!)
      mock.start {|server| server.inherit_io = true}
    end

    it 'should not inherit io by default' do
      expect(child).not_to receive(:io)
      mock.start
    end

    it 'allows you to block for the process to end by setting value in block' do
      expect(child).to receive(:wait)
      mock.start {|server| server.wait_for_process = true}
    end

    it 'should not wait by default' do
      expect(child).not_to receive(:wait)
      mock.start
    end

    it 'supplies command-line options' do
      expect(ChildProcess).to receive(:build).with('java', '-jar', 'wiremock-123.jar', '--port', '123').and_return(child)
      mock.start {|server| server.port = 123}
    end
  end

  describe 'stopping the server' do
    it 'shuts down the server process' do
      expect(Net::HTTP).to receive(:new).with('localhost', '8080').and_return http
      expect(http).to receive(:post).with('/__admin/shutdown', '')
      mock.stop
    end

    it 'allows you to override the default port by setting value in block' do
      expect(Net::HTTP).to receive(:new).with('localhost', '1234').and_return http
      mock.stop {|server| server.port = 1234}
    end
  end

  describe 'creating a stub message' do
    it 'creates a stub message' do
      expect(http).to receive(:post).with('/__admin/mappings/new', '{the message}')
      mock.stub('{the message}')
    end

    it 'allows a stub to be created on a remote machine' do
      expect(Net::HTTP).to receive(:new).with('remote_host', '8080').and_return http
      expect(http).to receive(:post).with('/__admin/mappings/new', '{the message}')
      mock.stub('{the message}') do |server|
        server.remote_host = 'remote_host'
      end
    end
  end

  describe 'creating a stub message from a file' do
    it 'reads the file and creates the stub' do
      file = double
      expect(File).to receive(:open).with('/path/to/file', 'rb').and_yield(file)
      expect(file).to receive(:read).and_return('file contents')
      allow(http).to receive(:post).with('/__admin/mappings/new', 'file contents')
      mock.stub_with_file('/path/to/file')
    end

    it 'allows parameters to be provided when setting up the call' do
      expect(Net::HTTP).to receive(:new).with('remote_host', '8080').and_return http
      allow(File).to receive(:open).with('/path/to/file', 'rb').and_return('file contents')
      allow(http).to receive(:post).with('/__admin/mappings/new', 'file contents')
      mock.stub_with_file('/path/to/file') do |server|
        server.remote_host = 'remote_host'
      end
    end
  end

  describe 'creating a stub message from an erb file and a hash of data' do
    it 'reads the file and uses the hash to create the stub' do
      file = double
      expect(File).to receive(:open).with('/path/to/file.erb', 'rb').and_yield(file)
      expect(file).to receive(:read).and_return('Name: <%= first %> <%= last %>')
      allow(http).to receive(:post).with('/__admin/mappings/new', 'Name: Sam Smith')
      mock.stub_with_erb('/path/to/file.erb', {first: 'Sam', last: 'Smith'})
    end

    it 'allows parameters to be provided when setting up the call' do
      expect(Net::HTTP).to receive(:new).with('remote_host', '8080').and_return http
      allow(File).to receive(:open).with('/path/to/file.erb', 'rb').and_return('Name: <%= first %> <%= last %>')
      allow(http).to receive(:post).with('/__admin/mappings/new', 'Name: Sam Smith')
      mock.stub_with_erb('/path/to/file.erb', {first: 'Sam', last: 'Smith'}) do |server|
        server.remote_host = 'remote_host'
      end
    end
  end

  describe 'saving the stubbed messages' do
    it 'saves the messages' do
      expect(http).to receive(:post).with('/__admin/mappings/save', '')
      mock.save
    end
  end

  describe 'resetting the stubs' do
    it 'resets only the stubs' do
      expect(http).to receive(:post).with('/__admin/mappings/reset', '')
      mock.reset_mappings
    end
  end

  describe 'resetting the entire server removing all mappings' do
    it 'resets everything' do
      expect(http).to receive(:post).with('/__admin/reset', '')
      mock.reset_all
    end
  end
end