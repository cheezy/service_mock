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

## Getting Started

This section is a high-level overview of how I typically use this gem in my projects.
I will skip over some details here but you can find them below.

Let's say that I have an application that is using many restful services.  I would
begin by starting up WireMock in proxy mode and make my application request the services
from the WireMock url (usually with a Rake task I would create). WireMock will create
two files for each service call - one that has the request / response structure and
one that has the response body.

Next I would take the files created by WireMock and turn them into my templates.  I do
this by updating values in the files to data elements.  For example, if I have some place
that had a persons last name I would put `<%= last_name %>` there. If I wanted to provide
a default that could be used I would use one of this gems ERB helper methods that allows
me to provide a default - `<%= value_with_default(last_name, 'Smith') %>`.  If there
is part of the message that repeats itself I might create a loop.  I can use any Ruby
code I want.

Once I have the templates created I then turn to my tests.  For each test I specify
the data that I need to merge with the templates or override the defaults.  I put this
data in my yml files.  Once I have the data file created I simply make the call in my
code to stub out the services.

## Usage

### Using the API

All interaction with the WireMock services is via calls to an instance of
`ServiceMock::Server`.  On your local machine you can `start` and `stop` an
instance of the server process.  On local and remote machines you can also
use one of several methods to create stubs (specify request/response data)
as well as tell the server to `save` in-memory stubs, `reset_mappings` to
remove all of the stubs you have provided and `reset_all` which completely
clears all mappings and files that you have setup for WireMock to return
as your system under test interacts with it.

When you create an instance of `ServiceMock::Server` you often need to provide
some additional information.  The _required_ piece of data is the version of WireMock
you will be using.  If the name of the WireMock jar file you will be using
is `wiremock-standalone-2.5.0.jar` then the version you should provide
is `standalone-2.5.0`.  In other words, take off the initial `wiremock-`
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
have default values of `false`.  If set to `true`, `inherit_io` will cause the
server instance to 'inherit' the standard out and in for the running WireMock
process.  When `wait_for_process` is set to `true` it will cause the
call to `start` to block until the underlying WireMock process exits.
These values can be overwritten in the call to `start` as described below.

#### Starting the Server

You start the server by calling the `start` method but it doesn't end there.
There are a large number of parameters you can set to control the way that
WireMock runs.  These are set via a block that is passed to the `start` method.

```ruby
my_server.start do |server|
  server.port = 8081
  server.record_mappings = true
  server.root_dir = '/path/to/root'
  server.verbose = true
end
```

The values that can be set are:

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
| classpath | Provides list of dependencies jar files to run with the standalone server, they could be extensions and their dependencies and should be kept in the same working directory with the standalone jar file. |
| extensions | Provides list of wiremock extensions main class to run with the standalone server. |

In addition, as mentioned before, you can set the `inherit_io` and `wait_for_process` options
to `true` inside of the block.

### Starting the Server with extensions

To start WireMock with extensions, we save the extensions and dependencies jar files in the working directory (default is `config/mocks`) and provide the `classpath` and `extensions` as following:

```ruby
my_server.start do |server|
  server.port = 8081
  server.record_mappings = true
  server.root_dir = /path/to/root
  server.verbose = true
  server.classpath = ['asm-1.0.2.jar', 'json-smart-2.2.1.jar', 'wiremock-body-transformer-1.1.1.jar']
  server.extensions = 'com.opentable.extension.BodyTransformer'
end
```

### Stubbing service calls

Please read the [WireMock stubbing](http://wiremock.org/stubbing.html)
documentation so you understand the message structures that are used.
It is very important that you understand this first. Those details will
not be covered here.

There are three methods that can be used to stub services.

```ruby
my_server.stub(string_containing_json_stub)

my_server.stub_with_file(file_containing_json_stub)

my_server.stub_with_erb(erbfile_containing_json_stub, hash_with_values)
```

The first method is pretty self-explanatory.  You simply pass a string
that contains the json stub and the server contacts the running server
process and sets it up.  The second method takes a full path to a file
that contains the json stub.

The third method is where things get interesting.  It allows you to provide
an [ERB](https://docs.puppet.com/puppet/latest/reference/lang_template_erb.html)
file that will become your json stub.  ERB stands for Embedded Ruby and
allows you to insert Ruby code inside any type of file - including json.
Using this ability allows us to build templates of the service messages.
It is quite common to mock a service many times in your test suite and 
while the structure is the same with each mock the data supplied and 
returned is different. Using templates allows us to simply write the 
template once and then supply the data for each mock.

The third method takes the full path to an erb file that contains the
json stub and a second parameter that is a `Hash` which provides the
data that is used to fill in the data elements in the template.

If you set the port value when you started the server you will need to
do the same via a block when stubbing.

```ruby
my_server.stub(string_containing_json_stub) do |server|
  server.port = 8081
end
```

If the WireMock instance is running on another server you will need to
provide the url so it can be found.  This is often necessary when you
are running your tests in a build pipeline or a continuous integration
server.  You can do this by setting the `remote_host` value like this:

```ruby
my_server.stub_with_erb(erbfile, values) do |server|
  server.remote_host = 'other_host_name'
end
```

Another way to set both the port and remote host is to set an instance
variable `WIREMOCK_URL`.  It should take the form 'http://hostname:port'.

### Stubbing multiple services

It is often necessary to stub multiple service calls in order to
complete a test.  ServiceMock has created a simple way to do this.
It is implemented in a class named `ServiceMock::StubCreator`.
This class has a single public method `create_stubs_with` which
takes the name of the file that has the data for all
of the stubs you wish to create and optional data to merge with
that file. Also, when you create an instance of the class it
requires you to pass an instance of `ServiceMock::Server`.

Another way to specify the file to use for creating the stubs is
to set a tag on the Cucumber Scenario.  Create a tag in the form of
`@servicemock_FILENAME` where `FILENAME` is the name of the
file you wish to use.  For example, if you add the tag
`@servicemock_foo` then the file `foo.yml` will be loaded.  The next
thing you will need to do is add the following code in a hook:

```ruby
Before do |scenario|
  ServiceMock.load_for_scenario(scenario)
end
```

At this time you need to setup everything in a specific directory
structure.  The directory it looks for is `config/mocks/stubs`.
Inside that directory it looks for two additional directories -
`data` and `templates`. The data file needed by the call needs
be located in the `data` directory and the `ERB` files (templates)
that it references needs to be in the `templates` directory.

The structure of the data file drives the stubbing.  Let's start
with an example.

```yml
service1.erb:
  first_name: Mickey
  last_name: Mouse

service2.erb:
  username: mmouse
  password: secret
```

With the above file the method call will mock two services.  It will first
of all read the file `service1.erb` from the `templates` directory and
stub it passing the data that is associated.  Next it will read the next
template file (`service2.erb`), etc.

The `create_stubs_with` method has an optional second parameter.  It is
a `Hash` that can be used to override a value that is contained within
our data file.  For example, if I wanted to override just the password
used in service2 from the example above I do this:

```ruby
stub_creater.create_stubs_with(filename, {'service2' => {'password' => 'updated'}})
```

### Disabling Stubbing

There might be some tests that you want to run sometimes against mocked
services and sometimes against the real services.  This is very simple
to do.  If you simply set the value of `ServieMock.disable_stubs` to
true all of the `stub_*` methods return immediately without stubbing 
anything. In practice you would simply point your application to the 
real services and disable the stubs via this flag.

### Other capabilities

There are additional methods that provide access to the running WireMock
server. If you changed the port during startup then you will need to do
so here as well.  The methods are:

```ruby
my_server.stop
```

Stops the running WireMock server if it is running locally.

```ruby
my_server.save
```

Writes all of the stubs to disk so they are available the next time
the server starts.

```ruby
my_server.reset_mappings
```

Removes the stubs that have been created since WireMock was started.

```ruby
my_server.reset_all
```

Removes all stubs, file based stubs, and request logs from the WireMock
server.


There are two methods that can be used in your ERB templates.  They are:

```ruby
render(path)
```
This will read the file at `path` and place its' contents in place of the call.
I use this to insert the body inside the response.

```ruby
value_with_default(value, default)
```
This call allows you to provide a default for the data that will be inserted into
the ERB template.  It can be used like this - 
`<%= value_with_default(city, 'Toronto') %>`

### Using the Rake Tasks

There are two rake tasks that are provided to make it easy to start and
stop the WireMock server when working locally.  You can simply add
the following to your `Rakefile`:

```ruby
require 'service_mock'
require 'service_mock/rake/rake_tasks'

WIREMOCK_VERSION = 'standalone-2.0.10-beta'
ServiceMock::Rake::StartServerTask.new(:start_server, WIREMOCK_VERSION)
ServiceMock::Rake::StopServerTask.new(:stop_server, WIREMOCK_VERSION)
```

Any parameter that can be passed to the `start` method can also be passed
to the rake task.

```ruby
ServiceMock::Rake::StartServerTask.new(:start_server, WIREMOCK_VERSION) do |server|
  server.port = 8081
  server.record_mappings = true
  server.root_dir = '/path/to/root'
  server.verbose = true
end
```

If you set the port in the start task then you will also need to set it
in the stop task.

```ruby
ServiceMock::Rake::StopServerTask.new(:stop_server, WIREMOCK_VERSION) do |server|
  server.port = 8081
end
```

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

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.



## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/cheezy/service_mock. This project is intended to
be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [Contributor Covenant](http://contributor-covenant.org)
code of conduct.

