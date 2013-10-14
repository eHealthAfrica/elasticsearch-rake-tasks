require "json"
require "helpers"

BASE_PATH = "resources/elasticsearch/"
TEMPLATES_PATH = "#{BASE_PATH}templates/"
SEED_PATH = "#{BASE_PATH}dumps/"

@es_server = "http://localhost:9200/"
@es_index = "default"

def ensure_elasticsearch_configuration_present!
  raise "ES_SERVER not set!" unless @es_server
  raise "ES_INDEX not set!" unless @es_index
end

def validate_elasticsearch_configuration!(server, index)
  raise "ES_SERVER not set!" unless server
  raise "ES_INDEX not set!" unless index
end

namespace :es do
  desc "Dump elasticsearch index from one into another"
  task :reindex, :server, :index, :to_index do |t, args|
    ensure_elasticsearch_configuration_present!

    server = args[:server]
    index = args[:index]
    to_index = args[:to_index]

    c = Eson::HTTP::Client.new(:server => server, :default_parameters => {:index => index})
    c.reindex(index, to_index)
  end

  desc "Seed the elasticsearch cluster with the data dump"
  task :seed, :server, :index do |t, args|
    server = args[:server]
    index = args[:index]

    validate_elasticsearch_configuration!(server, index)

    raise "need seed data in #{SEED_PATH}seed.json" unless File.exist?("#{SEED_PATH}seed.json")
    Elasticsearch::Helpers.curl_request("POST", "#{server}/#{index}/_bulk", "--data-binary @#{SEED_PATH}seed.json")
  end

  desc "Dump the elasticsearch index to the seed file"
  task :dump, :server, :index do |t, args|
    require "eson-http"
    require "eson-more"

    server = args[:server]
    index = args[:index]

    validate_elasticsearch_configuration!(server, index)

    c = Eson::HTTP::Client.new(:server => server, :default_parameters => {:index => index})
    # this is a workaround for a current bug that disallows passing auto_call directly to #bulk
    bulk_client = Eson::HTTP::Client.new(:auto_call => false)
    File.open("#{SEED_PATH}seed.json", "w") do |f|
      c.all(:index => index) do |chunk|
        if chunk.size > 0
          b = bulk_client.bulk do |b|
            chunk.each do |doc|
              b.index :index => nil,
                      :type => doc["_type"],
                      :id => doc["_id"],
                      :doc => doc["_source"]
            end
          end
          f << b.source
        end
      end
    end
  end

  Dir["#{TEMPLATES_PATH}*"].each do |folder|
    name = folder.split("/").last
    namespace name do
      desc "compile the #{name} template and prints it to STDOUT"
      task :compile do
        reader = Reader.new
        puts reader.compile_template(name)
      end

      desc "resets the given index, replacing the mapping with a current one"
      task :reset do
        ensure_elasticsearch_configuration_present!
        url = "#{@es_server}/#{@es_index}"
        curl_request("DELETE", url)
        curl_request("POST", url, "-d #{compile_template(name)}")
      end
    end
  end
end

