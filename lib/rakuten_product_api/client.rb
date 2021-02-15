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

    attr_accessor :sid, :username, :password, :consumer_key, :consumer_secret, :authenticate

    def initialize(sid:               RakutenProductApi.sid,
                   username:          RakutenProductApi.username,
                   password:          RakutenProductApi.password,
                   consumer_key:      RakutenProductApi.consumer_key,
                   consumer_secret:   RakutenProductApi.consumer_secret,
                   access_token:      nil,
                   access_expires_at: nil)

      @authenticate = Authenticate.new(sid: sid,
                                       username: username,
                                       password: password,
                                       consumer_key: consumer_key,
                                       consumer_secret: consumer_secret,
                                       access_token: access_token,
                                       access_expires_at: access_expires_at)

      @sid             = sid
      @username        = username
      @password        = password
      @consumer_key    = consumer_key
      @consumer_secret = consumer_secret
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
