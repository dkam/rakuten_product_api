# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rakuten_product_api"
require "minitest/autorun"

class MockHttpResponse
  attr_accessor :body, :code

  def initialize(body)
    @body = body
    @code = "200"
  end
end
