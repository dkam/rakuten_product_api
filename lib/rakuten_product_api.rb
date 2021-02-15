# frozen_string_literal: true

require "byebug"
require "json"
require_relative "rakuten_product_api/version"
require_relative "rakuten_product_api/client"
require_relative "rakuten_product_api/response"
require_relative "rakuten_product_api/item"

module RakutenProductApi
  class Error < StandardError; end

  APPLICATION_END_POINT = "https://api.rakutenmarketing.com/productsearch/1.0"

  class << self
    attr_accessor :sid,
                  :username,
                  :password,
                  :consumer_key,
                  :consumer_secret,
                  :mid,
                  :sort,
                  :sorttype

    def configure
      yield self
      true
    end
    alias config configure

    def hello
      puts "Oh Hai"
    end
  end
end
