# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_mock/version'

Gem::Specification.new do |spec|
  spec.name          = "service_mock"
  spec.version       = ServiceMock::VERSION
  spec.authors       = ["Jeffrey S. Morgan"]
  spec.email         = ["jeff.morgan@leandog.com"]

  spec.summary       = %q{Simple wrapper over WireMock}
  spec.description   = %q{Simple wrapper over WireMock}
  spec.homepage      = "https://github.com/cheezy/service_mock"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|config)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "childprocess", "~>0.5"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
