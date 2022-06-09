# frozen_string_literal: true

require "json"
require "forwardable"
require_relative "rakuten_product_api/version"
require_relative "rakuten_product_api/authenticate"
require_relative "rakuten_product_api/client"
require_relative "rakuten_product_api/response"
require_relative "rakuten_product_api/item"

module RakutenProductApi
  class Error < StandardError; end

  APPLICATION_END_POINT = "https://api.rakutenmarketing.com/productsearch/1.0"

  class << self
    attr_accessor :sid,
                  :mid,
                  :sort,
                  :sorttype,
                  :client_id,
                  :client_secret,
                  :endpoint

    def configure
      self.endpoint = 'https://api.linksynergy.com' # Set a default API Endpoint
      yield self
    end
    alias config configure
  end
end
