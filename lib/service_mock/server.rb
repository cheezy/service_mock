require 'childprocess'
require 'net/http'
require 'json'
require 'erb'
require 'ostruct'
require 'service_mock/erb_methods'

#
# All interaction with the WireMock services is via calls to an instance of
# +ServiceMock::Server+.  On your local machine you can +start+ and +stop+ an
# instance of the server process.  On local and remove machines you can also
# use one of several methods to create stubs (specify request/response data)
# as well as tell the server to +save+ in-memory stubs, +reset_mappings+ to
# remove all of the stubs you have provided and +reset_all+ which completely
# clears all mappings and files that you have setup for WireMock to return
# as your system under test interacts with it.
#
# When you create your instance of +ServiceMock::Server+ you need to provide
# some information.  The required piece of data is the version of WireMock
# you will be using.  If the name of the WireMock jar file you will be using
# is +wiremock-standalone-2.1.1-beta.jar+ then the version you should provide
# is +standalone-2.1.1-beta+.  In other words, take off the initial +wiremock-+
# and the trailing +.jar+ and this is your version.  The other optional value
# you can provide is the working directory - the location where the WireMock
# jar is located.  By default the working directory is set to +config/mocks+.
# You will initialize the server like this:
#
#   # uses default working directory
#   my_server = ServiceMock::Server.new('standalone-2.1.1-beta')
#
#   # or this sets the working directory
#   my_server = ServiceMock::Server.new('standalone-2.1.1-beta', '/path/to/jar')
#
# There are two additional values (inherit_io and wait_for_process) that
# are defaulted to +false+.  If set to +true+, +inherit_io+ will cause our
# instance to 'inherit' the standard out and in for the running WireMock
# process.  When +wait_for_process+ is set to +true+ it will cause the
# call to +start+ to block until the underlying WireMock process exits.
# These values can be overwritten in the call to +start+.
#

module ServiceMock
  class Server
    include CommandLineOptions

    attr_accessor :inherit_io, :wait_for_process, :remote_host, :classpath, :use_ssl
    attr_reader :wiremock_version, :working_directory, :process
    attr_accessor :proxy_addr, :proxy_port, :proxy_user, :proxy_pass

    def initialize(wiremock_version, working_directory = ::ServiceMock.working_directory)
      @wiremock_version = wiremock_version
      @working_directory = working_directory
      self.inherit_io = false
      self.wait_for_process = false
      self.use_ssl = false
    end

    #
    # You start the server by calling the `start` method but it doesn't end there.
    # There are a large number of parameters you can set to control the way that
    # WireMock runs.  These are set via a block that is passed to the `start` method.
    #
    #   my_server.start do |server|
    #     server.port = 8081
    #     server.record_mappings = true
    #     server.root_dir = /path/to/root
    #     server.verbose = true
    #   end
    #
    # The values that can be set are:
    #
    # [port]  The port to listen on for http request
    # [https_port] The port to listen on for https request
    # [https_keystore] Path to the keystore file containing an SSL certificate to use with https
    # [keystore_password] Password to the keystore if something other than "password"
    # [https_truststore] Path to a keystore file containing client certificates
    # [truststore_password] Optional password to the trust store.  Defaults to "password" if not specified
    # [https_reuire_client_cert] Force clients to authenticate with a client certificate
    # [verbose] print verbose output from the running process. Values are +true+ or +false+
    # [root_dir] Sets the root directory under which +mappings+ and +__files+ reside.  This defaults to the current directory
    # [record_mappings] Record incoming requests as stub mappings
    # [match_headers] When in record mode, capture request headers with the keys specified
    # [proxy_all] proxy all requests through to another URL. Typically used in conjunction with _record_mappings_ such that a session on another service can be recorded
    # [preserve_host_header] When in proxy mode, it passes the Host header as it comes from the client through to the proxied service
    # [proxy_via] When proxying requests, route via another proxy server. Useful when inside a corporate network that only permits internet access via an opaque proxy
    # [enable_browser_proxy] Run as a browser proxy
    # [no_request_journal] Disable the request journal, which records incoming requests for later verification
    # [max_request_journal_entries] Sets maximum number of entries in request journal.  When this limit is reached oldest entries will be discarded
    #
    # In addition, as mentioned before, you can set the +inherit_io+ and +wait_for_process+ options
    # to +true+ inside of the block.
    #
    def start
      yield self if block_given?
      classpath = self.classpath.is_a?(Array) ? self.classpath : []
      start_process(classpath)
    end

    #
    # Stops the running WireMock server if it is running locally.
    #
    def stop
      yield self if block_given?
      http.post('/__admin/shutdown', '')
    end

    #
    # Create a stub based on the value provided.
    #
    def stub(message)
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      http.post('/__admin/mappings/new', message)
    end

    #
    # Create a stub using the information in the provided filename.
    #
    def stub_with_file(filename)
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      content = File.open(filename, 'rb') { |file| file.read }
      stub(content)
    end

    #
    # Create a stub using the erb template provided.  The +Hash+ second
    # parameter contains the values to be inserted into the +ERB+.
    #
    def stub_with_erb(filename, hsh={})
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      template = File.open(filename, 'rb') { |file| file.read }
      erb_content = ERB.new(template).result(data_binding(hsh))
      stub(erb_content)
    end

    #
    # Get the count for the request criteria
    #
    def count(request_criteria)
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      JSON.parse(http.post('/__admin/requests/count', request_criteria).body)['count']
    end

    #
    # Get the count for the request criteria in the provided filename.
    #
    def count_with_file(filename)
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      content = File.open(filename, 'rb') { |file| file.read }
      count(content)
    end

    #
    # Get the count for the request criteria using the erb template
    # provided.  The +Hash+ second parameter contains the values to be
    # inserted into the +ERB+.
    #
    def count_with_erb(filename, hsh={})
      return if ::ServiceMock.disable_stubs
      yield self if block_given?
      template = File.open(filename, 'rb') { |file| file.read }
      erb_content = ERB.new(template).result(data_binding(hsh))
      count(erb_content)
    end

    #
    # Writes all of the stubs to disk so they are available the next time
    # the server starts.
    #
    def save
      yield self if block_given?
      http.post('/__admin/mappings/save', '')
    end

    #
    # Removes the stubs that have been created since WireMock was started.
    #
    def reset_mappings
      yield self if block_given?
      http.post('/__admin/mappings/reset', '')
    end

    #
    # Removes all stubs, file based stubs, and request logs from the WireMock
    # server.
    #
    def reset_all
      yield self if block_given?
      http.post('/__admin/reset', '')
    end

    private

    def data_binding(hsh)
      OpenStruct.include ::ServiceMock::ErbMethods
      OpenStruct.new(hsh).instance_eval { binding }
    end

    def start_process(classpath)
      @process = ChildProcess.build(*(start_command(classpath) + command_line_options))
      @process.cwd = working_directory
      @process.io.inherit! if inherit_io
      @process.start
      @process.wait if wait_for_process
    end

    def start_command(classpath)
      dependency_jars = classpath + ["wiremock-#{wiremock_version}.jar"]
      ['java', '-cp', dependency_jars.join(':'),
        'com.github.tomakehurst.wiremock.standalone.WireMockServerRunner']
    end

    def http
      if using_proxy
        http = Net::HTTP.Proxy(proxy_addr, proxy_port,
                        proxy_user, proxy_pass)
      else
        http = Net::HTTP.new(admin_host, admin_port)
      end
      http.use_ssl = use_ssl
      http
    end

    def using_proxy
      proxy_addr && proxy_port
    end

    def admin_host
      return ENV['WIREMOCK_URL'].match(/http\:\/\/(.+)\:\d+/)[1] if ENV['WIREMOCK_URL']
      "#{remote_host ? remote_host : 'localhost'}"
    end

    def admin_port
      self.port = ENV['WIREMOCK_URL'].match(/http\:\/\/.+\:(\d*)/)[1] if ENV['WIREMOCK_URL']
      "#{port ? port.to_s : '8080'}"
    end

  end
end
