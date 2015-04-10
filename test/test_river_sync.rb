require File.expand_path '../test_helper.rb', __FILE__

class TestRiverSync < Minitest::Test
  def status(*seqs)
    {"hits"=>{ "hits"=> seqs }}
  end

  def sequence(type, seq)
    {"_index"=>"_river", "_type"=>type, "_id"=>"_seq", "_source"=>{"couchdb"=>{"last_seq"=>seq}}}
  end

  def setup
    template = { "couchdb" => {}, "index" => { "index" => ""}}
    @file = 'test/test_file.json'
    File.open(@file, 'w+') { |f| f.write(template.to_json)}
    @old_type = 'gin_call_centre_9'
    @new_type = 'gin_call_centre_10'
    @sync = Ehealth::River::Sync.new(Elasticsearch::Client.new, @old_type, @new_type, @file)
  end

  def teardown
    File.delete(@file) if File.exist?(@file)
  end

  def test_latest_seq_no_river_present
    @sync.send(:client).stub :search, status do
      assert_raises(Exception) { @sync.send(:last_seq, @old_type) }
    end
  end

  def test_latest_seq_a_single_river_present
    seq = "1011207"
    @sync.send(:client).stub :search, status(sequence(@old_type, seq)) do
      assert_equal seq, @sync.send(:last_seq, @old_type)
    end
  end

  def test_not_in_sync
    seq = 0
    seqs = [sequence(@old_type, seq.to_s), sequence(@new_type, "#{seq + 1}")]
    @sync.send(:client).stub :search, status(*seqs) do
      refute @sync.send(:sync?), 'should not be in sync'
    end
  end

  def test_in_sync
    seq = 0
    seqs = [sequence(@old_type, seq.to_s), sequence(@new_type, seq.to_s)]
    @sync.send(:client).stub :search, status(*seqs) do
      assert @sync.send(:sync?), 'should be in sync'
    end
  end

  def test_set_sequence_call
    seq = "1011207"
    @sync.send(:client).stub :search, status(sequence(@old_type, seq)) do
      @sync.send(:client).stub :index, ->(x) { x.to_s } do
        assert_equal "{:index=>\"_river\", :type=>\"gin_call_centre_10\", :id=>\"_seq\", :body=>{:couchdb=>{:last_seq=>\"#{seq}\"}}}" , @sync.set_sequence(seq).call
      end
    end
  end

  def test_put_river
    @sync.send(:client).stub :index, ->(x) { x.to_s } do
      assert_equal "{:index=>\"_river\", :type=>\"gin_call_centre_10\", :id=>\"_meta\", :body=>{\"couchdb\"=>{}, \"index\"=>{\"index\"=>\"gin_call_centre_10\"}}}", @sync.put_river.call
    end
  end

  def test_put_authenticated_river
    @sync = Ehealth::River::Sync.new(Elasticsearch::Client.new, @old_type, @new_type, @file, 'foo', 'bar')
    @sync.send(:client).stub :index, ->(x) { x.to_s } do
      assert_equal "{:index=>\"_river\", :type=>\"gin_call_centre_10\", :id=>\"_meta\", :body=>{\"couchdb\"=>{\"user\"=>\"foo\", \"password\"=>\"bar\"}, \"index\"=>{\"index\"=>\"gin_call_centre_10\"}}}" , @sync.put_river.call
    end
  end
end
