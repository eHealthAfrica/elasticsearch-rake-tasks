require 'rake'
require 'helper'
# The checks if an index and its previous are in sync
#
# Author::    eHealthAfrica (mailto:oss@ehealthafrica.org)
# Copyright:: eHealth Systems Africa Foundation
# License::  Apache-2.0

module Ehealth
  class ChecksIndexAndRiverInSync
    include Helper

    def initialize(client, new_index, old_index = nil)
      @client = client
      @new_index = new_index
      @old_index = old_index || previous_index(new_index)
    end

    def sync?
      number_of_documents(@old_index) === number_of_documents(@new_index)
    end

    def index_sync?
    end

    def river_sync?
    end

    def number_of_documents(index)
       @client.search(index: index)["hits"]["total"]
    end
  end
end
