require 'service_mock/version'
require 'service_mock/command_line_options'
require 'service_mock/server'
require 'service_mock/render_subtemplate'
require 'service_mock/rake/rake_tasks'

#
# ServiceMock is a Ruby gem that provides a wrapper over the [WireMock](http://wiremock.org)
# library.  The gem provides the ability to perform many actions on a WireMock instance
# including starting, stopping, and several ways to stub out calls.  It is highly
# recommended that you take the time to read the WireMock documentation and understand
#the how the library works.
#
# This gem can be used to help you virtualize services for your tests.  For example, if you
# are unable to achieve effective test data management with the backend systems you can
# use this gem (with WireMock) to simulate (or mock) the services while controlling the
# data that is returned.
#
# ServiceMock also provides two built-in rake task that can be used to start and stop an
# instance of WireMock.  The rake task need to be executed on the machine that the server
# will run - there is no ability for remote start and stop.
#
module ServiceMock

end


