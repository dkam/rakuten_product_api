require "uri"
require "net/http"
require "net/https"
require "base64"
require "json"

module RakutenProductApi
  class Authenticate
    REFRESH_TOKEN_LEEWAY = 60 * 10 # Ten minutes prior to expiry we should refresh token
    attr_accessor :sid, :username, :password, :consumer_key, :consumer_secret, :access_token, :access_expires_at

    def initialize(sid:               RakutenProductApi.sid,
                   username:          RakutenProductApi.username,
                   password:          RakutenProductApi.password,
                   consumer_key:      RakutenProductApi.consumer_key,
                   consumer_secret:   RakutenProductApi.consumer_secret,
                   access_token:      nil,
                   access_expires_at: nil)

      @sid               = sid
      @username          = username
      @password          = password
      @consumer_key      = consumer_key
      @consumer_secret   = consumer_secret
      @access_token      = access_token
      @access_expires_at = access_expires_at
    end

    def auth_header
      ensure_authentication
      "Bearer #{@access_token}"
    end

    def request_auth_token
      Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}").strip
    end

    def api_request_auth
      res = auth_request(
        "https://api.rakutenmarketing.com/token",
        { grant_type: "password", username: @username, password: @password, scope: @sid }
      )

      process_auth_response(res)

      @access_expires_at = Time.now.to_i + @expires_in
    end

    def refresh_api_request_auth
      res = auth_request(
        "https://api.rakutenmarketing.com/token",
        { grant_type: "refresh_token", refresh_token: @refresh_token, scope: "Production" }
      )

      process_auth_response(res)

      @access_expires_at = Time.now.to_i + @expires_in
    end

    def process_auth_response(res)
      if res.code == "200"
        doc = JSON.parse(res.body)
        @expires_in    = doc["expires_in"]&.to_i
        @refresh_token = doc["refresh_token"]
        @access_token  = doc["access_token"]
      else
        puts "RESPONSE CODE #{res.code} received"
        res
      end
    end

    def auth_request(url, payload)
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = "Basic #{request_auth_token}"

        req.set_form_data(payload)
        http.request(req)
      end
    end

    def ensure_authentication
      if @access_expires_at.nil?
        # puts "NIL: getting auth"
        api_request_auth
      elsif Time.now.to_i > @access_expires_at
        # puts "EXPIRED: getting auth"
        api_request_auth
      elsif Time.now.to_i > (@access_expires_at + REFRESH_TOKEN_LEEWAY)
        # puts "REFRESH LEEWAY: getting auth"
        refresh_api_request_auth
      end
    end
  end
end
