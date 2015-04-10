require 'rake'
require 'helper'
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
  class BuildsReindexerArgs
    include Helper

    attr_reader :client

    # index is the common index name
    def initialize(client, common_index_name = nil)
      @client = client
      @common_index_name = common_index_name
    end

    def build
      selector = ->(x) { x =~ /#{@common_index_name}/ }
      sorter = ->(a, b) { version(a) <=> version(b) }
      begin
        old_index = last(@client.indices.status["indices"].keys, selector, sorter)
        new_index = "#{@common_index_name}_#{version(old_index) + 1}"
        [old_index, new_index]
      rescue Exception => e
        raise Exception.new("Exception raised #{e.message}, possibly nothing to reindex, due to index with common pattern: #{@common_index_name} missing")
      end
    end
  end
end
