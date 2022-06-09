require "uri"
require "net/http"
require "net/https"
require "base64"
require "nokogiri"

module RakutenProductApi
  class Client
    extend Forwardable
    def_delegators :@authenticate, :access_token, :access_expires_at
    REFRESH_TOKEN_LEEWAY = 60 * 10 # Ten minutes prior to expiry we should refresh token

    attr_accessor :sid, :username, :password, :authenticate

    def initialize(sid: RakutenProductApi.sid,
                   endpoint: RakutenProductApi.endpoint,
                   access_token: nil,
                   access_token_expires_at: nil)
  
      @sid = sid
      @endpoint = endpoint

      @authenticate = Authenticate.new(sid: sid,
                                       access_token: access_token,
                                       access_token_expires_at: access_token_expires_at)

    end

    def search(**options)
      params = %i{ keyword exact one none cat language max pagenumber mid, sort, sorttype }
      allowed_options = options.select {|k, v| params.include?(k)}
      Response.new(api_request(options, '/productsearch/1.0'))
    end

    def api_request(payload, path)
      params = payload.map { |k, v| "#{k}=#{v}" }.join("&")

      uri = URI("#{@endpoint}#{path}?#{params}")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req["Authorization"] = @authenticate.auth_header
        req["Accept"] = "application/xml"

        http.request(req)
      end

      puts "RESPONSE CODE #{res.code} received" if res.code != "200"

      res
    end
  end
end
