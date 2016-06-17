# ServiceMock

ServiceMock is a Ruby gem that provides a wrapper over the [WireMock](http://wiremock.org)
library.  The gem provides the ability to perform many actions on a WireMock instance
including starting, stopping, and several ways to stub out calls.

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
you can provide is the working directory - the location from where the WireMock
server process can be started from.  By default the working directory is
set to `config/mocks`.  You will initialize the server like this:

```ruby
# uses default working directory
my_server = ServiceMock::Server.new('standalone-2.0.10-beta')
 
# or this sets the working directory
my_server = ServiceMock::Server.new('standalone-2.0.10-beta', '/path/to/dir')
```

There are two additional values (inherit_io and wait_for_process) that 
are defaulted to `false`.  If set to `true`, `inherit_io` will cause our
instance to 'inherit' the standard out and in for the running WireMock
process.  When `wait_for_process` is set to `true` it will cause the
call to `start` to block until the underlying WireMock process exits.
These values can be overwritten in the call to `start` as described below.

#### Starting the Server

If you are starting an instance of WireMock with this gem there are a number
of options you can provide.  You do this via a block when you call start.

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

