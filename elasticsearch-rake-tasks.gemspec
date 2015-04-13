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
  spec.files         = ["Gemfile", "elasticsearch-rake-tasks.gemspec", "lib/elasticsearch-rake-tasks.rake", "lib/elasticsearch-rake-tasks.rb", "lib/elasticsearch/io/bulk_sink.rb", "lib/elasticsearch/io/chunked_sender.rb", "lib/elasticsearch/logging.rb", "lib/elasticsearch/rake/tasks.rb", "lib/elasticsearch/rake/tasks/index_dump.rb", "lib/elasticsearch/rake/tasks/seeder.rb", "lib/elasticsearch/rake/tasks/version.rb", "lib/elasticsearch/template/compiler.rb", "lib/elasticsearch/template/mappings_reader.rb", "lib/river/checks_index_and_river_in_sync.rb", "lib/river/helper.rb", "lib/river/reindexer.rb", "lib/river/river_sync.rb", "lib/river/tasks/reindex.rake", "spec/integration/elasticsearch/template/compiler_spec.rb", "spec/integration/elasticsearch/template/mappings_reader_spec.rb", "spec/integration/examples/templates/include/mappings/alias.yml", "spec/integration/examples/templates/include/mappings/bar.yml", "spec/integration/examples/templates/include/settings.yaml", "spec/integration/examples/templates/simple/mappings/bar.yml", "spec/integration/examples/templates/simple/mappings/foo.yml", "spec/integration/examples/templates/simple/settings.yaml", "spec/integration/examples/templates/simple/template_pattern", "spec/spec_helper.rb", "spec/unit/elasticsearch/io/chunked_sender_spec.rb", "test/test_helper.rb", "test/test_reindexer.rb", "test/test_river_sync.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "lib/river"]

  spec.add_dependency "faraday", '= 0.8.9'
  spec.add_dependency "eson", '= 0.8.0'
  spec.add_dependency "eson-more", '= 0.8.0'
  spec.add_dependency "elasticsearch", '= 1.0.1'
  spec.add_dependency "activesupport", '~> 3.2.0'
  spec.add_dependency "psych-inherit-file", '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "minitest"
end
