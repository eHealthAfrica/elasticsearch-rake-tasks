require 'helper'
require 'rake'
require 'json'
# The program takes an initial hosta and index name from
# the command line.
# It creates the next version to that index and
# reindex the data.
# If no old version exists it throws an error
#
#
# Author::    eHealthAfrica (mailto:oss@ehealthafrica.org)
# Copyright:: eHealth Systems Africa Foundation
# License::  Apache-2.0


module Ehealth
  module River
    module Endpoints
      def index; "_river"; end
      def id; "_seq"; end
      def meta; "_meta"; end
    end

    class Sync
      include Helper
      include Endpoints


      # we map river types to indeces
      def initialize(client, old_type, new_type, river_template, user=nil, password=nil)
        @client = client
        @old_type = old_type
        @new_type = new_type
        @river = update_template(JSON.parse(File.read(river_template)), new_type, user, password)
      end

      # a river type is mapped 1 to 1 to an index
      def update_template(template, index, user, password)
        template['index']['index'] = index
        if user && password
          template['couchdb']['user'] = user
          template['couchdb']['password'] = password
        end
        template
      end

      def delete_on_sync
        sleep 5 #something more elegant needs to be done here
        until sync? do
          sleep 1
        end
        delete
      end

      def set_sequence(seq)
        p "setting sequence"
       ->{ client.index index: index, type: @new_type, id: id, body: { couchdb: { last_seq: seq} } }
      end

      def put_river
        p "creating river of type #{@new_type} mapping to index #{@river['index']['index']}"
       ->{ client.index index: index, type: @new_type, id: meta, body: @river}
      end

      def old_type_last_seq
        last_seq(@old_type)
      end

      def last_seq(type)
        selector = ->(x) { x['_id'] == id && x['_type'] == type }
        rivers = client.search(index: index)["hits"]["hits"]
        sorter = ->(a, b) { version(a['type']) <=> version(b['type']) }
        begin
          last(rivers, selector, sorter)["_source"]["couchdb"]["last_seq"]
        rescue Exception => e
          raise Exception.new("error: #{e.message}, possibly current river for type #{type}")
        end
      end

      private

      def sync?
        a = last_seq(@old_type)
        b = last_seq(@new_type)
        p "previous #{a} - next #{b}"
        a === b
      end

      def client
        @client
      end

      def delete
        client.indices.delete_mapping({index: index, type: @old_type})
        p "deleted river with type #{@old_type}"
      end

    end
  end
end
