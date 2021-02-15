require 'forwardable'

module RakutenProductApi
  class Item
    extend Forwardable
    attr_accessor :raw

    def_delegators :@raw, :xpath, :at_xpath

    def initialize(data)
      @raw = data
    end

    def title
      get 'productname'
    end

    def merchant
      get 'merchantname'
    end
    
    def price
      [at_xpath("saleprice")&.text, at_xpath("saleprice/@currency")&.text]
    end
    
    def rrp
      [at_xpath("price")&.text, at_xpath("price/@currency")&.text]
    end

    def upc
      get 'upccode'
    end

    def isbn 
      at_xpath("sku")&.text[/97[98]\d{10}/] || at_xpath("keywords")&.text[/97[98]\d{10}/]
    end

    def link
      get 'linkurl'
    end

    def image_url
      get 'imageurl'
    end
    
    def used?
      description.match?( /used/i )
    end
    
    def new?
      !used?
    end

    def get(path)
      return nil if path.nil? || path.empty?
      @raw.at_xpath(path)&.text
    end
    def result_count
      @raw.at_xpath("result/item").count
    end
    
    def method_missing(method_name, *args, &block)
      return get(method_name.to_s) unless get(method_name.to_s).nil?

      super
    end
      
  end
end