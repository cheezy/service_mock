require 'yaml'

#
# ServiceMock::StubCreator is a class that can stub a set
# of services by reading a yaml file.
#

module ServiceMock
  class StubCreator

    attr_reader :server, :data

    def initialize(server)
      @server = server
      validate_server
    end

    def create_stubs_with(data_file)
      read_data(data_file)
      create_stubs
    end

    private

    def read_data(data_file)
      filename = "#{stubs_dir}/data/#{data_file}"
      data_contents = File.open(filename, 'rb') { |file| file.read }
      @data = ::YAML.load(data_contents)
    end

    def create_stubs
      data.each_key do |key|
        template_file = "#{stubs_dir}/templates/#{key}"
        server.stub_with_erb(template_file, data[key])
      end
    end

    def stubs_dir
      File.expand_path("#{::ServiceMock::WORKING_DIRECTORY}/stubs")
    end

    def validate_server
      error_message = "You must provide an instance of ::ServiceMock::Server!\n"
      begin
        raise error_message unless  server.wiremock_version.length > 0 and
                                    server.working_directory.length > 0
      rescue
        raise error_message
      end
    end
  end
end
