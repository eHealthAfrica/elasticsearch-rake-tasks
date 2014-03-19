require 'active_support/core_ext/hash/deep_merge'

module Elasticsearch
  module Template
    class MappingsReader
      attr_reader :path
      attr_reader :parser

      def initialize(template_path)
        @path   = template_path
        @parser = Elasticsearch::Yaml::Parser.new
      end

      def read
        mappings = {}
        Dir.chdir("#{path}/mappings") do
          visible_types.each do |path|
            name, _ = path.split(".")
            content = parser.parse_yaml_file(path).to_ruby
            mappings[name] = content
          end
        end
        mappings
      rescue
        {}
      end

      def visible_types
        paths = Dir['*.{yml,yaml}']
        paths.reject{ |p| File.basename(p).start_with?("_") }
      end
    end
  end
end
