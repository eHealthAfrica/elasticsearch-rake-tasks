# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsearch/rake/tasks/version'

Gem::Specification.new do |spec|
  spec.name          = "elasticsearch-rake-tasks"
  spec.version       = Elasticsearch::Rake::Tasks::VERSION
  spec.authors       = ["Florian Gilcher"]
  spec.email         = ["florian.gilcher@asquera.de"]
  spec.description   = %q{A set of rake tasks to interact with Elasticsearch: generate mappings, push them, update them.}
  spec.summary       = %q{rake tasks for Elasticsearch}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "lib/river"]

  spec.add_dependency "faraday"
  spec.add_dependency "eson"
  spec.add_dependency "eson-more"
  spec.add_dependency "elasticsearch"
  spec.add_dependency "activesupport", '~> 3.2.0'
  spec.add_dependency "psych-inherit-file", '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "minitest"
end
