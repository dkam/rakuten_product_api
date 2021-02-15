# frozen_string_literal: true

require "test_helper"

class RakutenProductApiTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RakutenProductApi::VERSION
  end

  def test_it_does_something_useful
    http_resp = MockHttpResponse.new(File.read("test/test_data/search_1.xml"))
    response = RakutenProductApi::Response.new(http_resp)
    assert_equal 7, response.items.count

    item = response.items.first
    assert_equal "All Systems Red", item.title
    assert_equal ["All Systems Red", "Adventure Sci Fi", "Science Fiction", "9781501977824"], item.keywords
  end
end
