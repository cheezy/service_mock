# ServiceMock

ServiceMock is a Ruby gem that provides a wrapper over the [WireMock](http://wiremock.org)
library.  The gem provides the ability to perform many actions on a WireMock instance
including starting, stopping, and several ways to stub out calls.  It is highly
recommended that you take the time to read the WireMock documentation and understand
the how the library works.

This gem can be used to help you virtualize services for your tests.  For example, if you
are unable to achieve effective test data management with the backend systems you can
use this gem (with WireMock) to simulate (or mock) the services while controlling the
data that is returned.

ServiceMock also provides two built-in rake task that can be used to start and stop an
instance of WireMock.  The rake task need to be executed on the machine that the server
will run - there is no ability for remote start and stop.

## Usage

### Using the API

All interaction with the WireMock services is via calls to an instance of
`ServiceMock::Server`.  On your local machine you can `start` and `stop` an
instance of the server process.  On local and remove machines you can also
use one of several methods to create stubs (specify request/response data)
as well as tell the server to `save` in-memory stubs, `reset_mappings` to
remove all of the stubs you have provided and `reset_all` which completely
clears all mappings and files that you have setup for WireMock to return
as your system under test interacts with it.

When you create your instance of `ServiceMock::Server` you need to provide
some information.  The required piece of data is the version of WireMock
you will be using.  If the name of the WireMock jar file you will be using
is `wiremock-standalone-2.0.10-beta.jar` then the version you should provide
is `standalone-2.0.10-beta`.  In other words, take off the initial `wiremock-`
and the trailing `.jar` and this is your version.  The other optional value
you can provide is the working directory - the location where the WireMock
jar is located.  By default the working directory is set to `config/mocks`.
You will initialize the server like this:

```ruby
# uses default working directory
my_server = ServiceMock::Server.new('standalone-2.0.10-beta')
 
# or this sets the working directory
my_server = ServiceMock::Server.new('standalone-2.0.10-beta', '/path/to/jar')
```

There are two additional values (inherit_io and wait_for_process) that 
are defaulted to `false`.  If set to `true`, `inherit_io` will cause our
instance to 'inherit' the standard out and in for the running WireMock
process.  When `wait_for_process` is set to `true` it will cause the
call to `start` to block until the underlying WireMock process exits.
These values can be overwritten in the call to `start` as described below.

#### Starting the Server

You start the server by calling the `start` method but it doesn't end there.
There are a large number of parameters you can set to control the way that
WireMock runs.  These are set via a block that is passed to the `start` method.

```ruby
my_server.start do |server|
  server.port = 8080
  server.record_mappings = true
  server.root_dir = /path/to/root
  server.verbose = true
end
```

The entire set of values that can be set are:

| value  | description  |
|--------|--------------|
| port  | The port to listen on for http request |
| https_port | The port to listen on for https request |
| https_keystore | Path to the keystore file containing an SSL certificate to use with https |
| keystore_password | Password to the keystore if something other than "password" |
| https_truststore | Path to a keystore file containing client certificates |
| truststore_password | Optional password to the trust store.  Defaults to "password" if not specified |
| https_reuire_client_cert | Force clients to authenticate with a client certificate |
| verbose | print verbose output from the running process. Values are `true` or `false` |
| root_dir | Sets the root directory under which `mappings` and `__files` reside.  This defaults to the current directory |
| record_mappings | Record incoming requests as stub mappings |
| match_headers | When in record mode, capture request headers with the keys specified |
| proxy_all | proxy all requests through to another URL. Typically used in conjunction with `record_mappings` such that a session on another service can be recorded |
| preserve_host_header | When in proxy mode, it passes the Host header as it comes from the client through to the proxied service |
| proxy_via | When proxying requests, route via another proxy server. Useful when inside a corporate network that only permits internet access via an opaque proxy |
| enable_browser_proxy | Run as a browser proxy |
| no_request_journal | Disable the request journal, which records incoming requests for later verification |
| max_request_journal_entries | Sets maximum number of entries in request journal.  When this limit is reached oldest entries will be discarded |

In addition, as mentioned before, you can set the `inherit_io` and `wait_for_process` options
to `true` inside of the block.



### Using the Rake Tasks


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'service_mock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install service_mock


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cheezy/service_mock. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

