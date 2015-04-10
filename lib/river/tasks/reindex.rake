#!/usr/bin/env bundle exec ruby
$LOAD_PATH.unshift 'lib/river'
require 'elasticsearch'
require 'reindexer'
require 'checks_index_and_river_in_sync'
require 'river_sync'


def with_managed_river river_sync_manager
  seq = river_sync_manager.old_type_last_seq
  log_info "current river sequence is :#{seq}"
  yield
  river_sync_manager.set_sequence(seq).call
  river_sync_manager.put_river.call
end

def reindex(couchdb_db, host, path, username=nil, password=nil)
  client = Elasticsearch::Client.new host: host
  old_index, new_index = Ehealth::BuildsReindexerArgs.new(client, couchdb_db).build
  river_sync_manager = Ehealth::River::Sync.new(client, old_index, new_index, path, username, password)
  with_managed_river river_sync_manager do
    Rake::Task['es:reindex'].invoke(host, old_index, new_index)
  end
  river_sync_manager
end

def defaults args
  args.with_defaults(
    :host => 'http://localhost:9200',
    :path =>  "resources/elasticsearch-couchdb-river/rivers/#{args[:couchdb_db]}.json"
  )
end

namespace :ehealth_es do
  desc 'Reindex with data source couchdb_db, setups a new river for it. Authentication for river is passed if provided. NOTE *the number of rivers setup for that before running should be db\_name < 2*'
  task :reindex, :couchdb_db, :host, :path, :username, :password do |t, args|
    defaults(args)
    begin
      reindex(args[:couchdb_db], args[:host], args[:path], args[:usename], args[:password])
    rescue Exception => e
      log_info "Not reindexed: #{e.message}"
    end
  end

  desc 'test if an index and its river are in sync with previous one'
  task :in_sync, :host, :index, :previous_index do |t, args|
    defaults(args)
    log_info Ehealth::ChecksIndexAndRiverInSync.new(Elasticsearch::Client.new(host: args[:host]), args[:index], args[:previous_index]).sync?
  end

  desc 'Reindex with data source couchdb_db, setups a new river for it and deletes previous river. Authentication for river is passed if provided. NOTE *the number of rivers setup for that before running should be db\_name < 2*'
  task :reindex_and_delete_previous_river, :couchdb_db, :host, :path, :username, :password do |t, args|
    defaults(args)
    begin
      reindex(args[:couchdb_db], args[:host], args[:path], args[:usename], args[:password]).delete_on_sync
    rescue Exception => e
      log_info "Not reindexed or not Deleted previous river: #{e.message}"
    end
  end
end
