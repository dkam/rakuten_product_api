require 'nokogiri'

module RakutenProductApi
  class Response
    attr_reader :http_response, :raw, :datas, :doc, :items

    def initialize(response)
      @http_response = response
      @raw = Nokogiri::XML(response.body)

      @items = @raw.xpath("result/item").map {|d| Item.new(d)}
    end
    
    def body
      @raw.to_s
    end
  end
end