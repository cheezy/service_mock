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

