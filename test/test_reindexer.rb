require File.expand_path '../test_helper.rb', __FILE__

class TestReindexer < Minitest::Test
  def setup
    @reindexer = Ehealth::BuildsReindexerArgs.new(Elasticsearch::Client.new, 'index')
  end

  def test_build_when_no_index_in_es
    @reindexer.send(:client).stub :indices, status: { 'indices' => {}} do
      assert_raises(Exception) { @reindexer.send(:build) }
    end
  end

  def test_build_when_index_not_in_es
    @reindexer.send(:client).stub :indices, status: { 'indices' => {'other' => {}}} do
      assert_raises(Exception) { @reindexer.send(:build) }
    end
  end

  def test_build_when_index_in_es
    @reindexer.send(:client).stub :indices, OpenStruct.new(status: { 'indices' => {'index_3' => {}}}) do
      assert_equal ['index_3', 'index_4'], @reindexer.send(:build)
    end
  end

  def test_initialize_when_no_es_available
    @reindexer.send(:client).stub :indices, -> { raise Exception.new("problem connecting to ES") } do
      assert_raises(Exception) { @reindexer.send(:build) }
    end
  end

  def test_river_sequence
  end

end
