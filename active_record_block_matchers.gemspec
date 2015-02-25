# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "active_record_block_matchers/version"

Gem::Specification.new do |spec|
  spec.name          = "active_record_block_matchers"
  spec.version       = ActiveRecordBlockMatchers::VERSION
  spec.authors       = ["Nathan Wallace"]
  spec.email         = ["nathan.m.wallace@gmail.com"]

  spec.summary       = %q{Additional RSpec custom matchers for ActiveRecord}
  spec.description   = %q{This gem adds custom block expectation matchers for RSpec, such as `expect { ... }.to create_a_new(User)`}
  spec.homepage      = "https://github.com/nwallace/active_record_block_matchers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", ">= 3.2.0"
  spec.add_dependency "rspec", ">= 3.0.0"

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.10.1"
  spec.add_development_dependency "sqlite3", "~> 1.3.10"
  spec.add_development_dependency "standalone_migrations", "~> 2.1.5"
end
