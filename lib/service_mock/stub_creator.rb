require 'yaml'

#
# ServiceMock::StubCreator is a class that can stub a set
# of services by reading a yaml file.
#
# It is often necessary to stub multiple service calls in order to
# complete a test.  ServiceMock has created a simple way to do this.
# It is implemented in a class named `ServiceMock::StubCreator`.
# This class has a single public method `create_stubs_with` which
# takes the name of the name of a file that has the data for all
# of the stubs you wish to create and optional data to merge with
# that file. Also, when you create an instance of the class it
# requires you to pass an instance of `ServiceMock::Server`.
#
# At this time you need to setup everything in a specific directory
# structure.  The directory it looks for is `config/mocks/stubs`.
# Inside that directory it looks for two additional directories -
# `data` and `templates`. The data file needed by the call needs
# be located in the `data` directory and the `ERB` files (templates)
# that it references needs to be in the `templates` directory.
#
# The structure of the data file drives the stubbing.  Let's start
# with an example.
#
# ```yml
# service1.erb:
#   first_name: Mickey
#   last_name: Mouse
#
# service2.erb:
#   username: mmouse
#   password: secret
# ```
#
# With the above file the method call will mock to services.  It will first
# of all read the file `service1.erb` from the `templates` directory and
# stub it passing the data that is associated.  Next it will read the next
# template file, etc.
#

module ServiceMock
  class StubCreator

    attr_reader :server, :data

    def initialize(server)
      @server = server
      validate_server
    end

    def create_stubs_with(data_file, to_merge = {})
      return if ::ServiceMock.disable_stubs
      read_data(data_file)
      merge_data(to_merge) unless to_merge.empty?
      create_stubs
    end

    private

    def read_data(data_file)
      filename = "#{stubs_dir}/data/#{data_file}"
      data_contents = File.open(filename, 'rb') { |file| file.read }
      @data = ::YAML.load(data_contents)
    end

    def merge_data(to_merge)
      data.each_key do |key|
        data[key].merge!(to_merge[key])
      end
    end

    def create_stubs
      data.each_key do |key|
        template_file = "#{stubs_dir}/templates/#{key}"
        server.stub_with_erb(template_file, data[key])
      end
    end

    def stubs_dir
      File.expand_path("#{::ServiceMock.working_directory}/stubs")
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
