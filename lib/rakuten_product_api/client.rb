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
                   access_token: nil,
                   access_token_expires_at: nil)
  
      @sid = sid
      @authenticate = Authenticate.new(sid: sid,
                                       access_token: access_token,
                                       access_token_expires_at: access_token_expires_at)

    end

    def search(keyword: nil, **options)
      Response.new(api_request(options.merge(keyword: keyword)))
    end

    def api_request(payload)
      params = payload.map { |k, v| "#{k}=#{v}" }.join("&")
      uri = URI("https://api.rakutenmarketing.com/productsearch/1.0?#{params}")

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
