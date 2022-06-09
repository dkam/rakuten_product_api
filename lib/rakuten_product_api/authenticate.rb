require "uri"
require "net/http"
require "net/https"
require "base64"
require "json"

module RakutenProductApi
  class Authenticate
    REFRESH_TOKEN_LEEWAY = 60 * 10 # Ten minutes prior to expiry we should refresh token
    attr_accessor :sid, :endpoint, :access_token, :access_token_expires_at, :refresh_token

    def initialize( sid:               RakutenProductApi.sid,
                    client_id:         RakutenProductApi.client_id,
                    client_secret:     RakutenProductApi.client_secret,
                    endpoint:          RakutenProductApi.endpoint,
                    access_token:      nil,
                    access_token_expires_at: nil)

      @sid               = sid # account-id ?
      @access_token      = access_token
      @access_token_expires_at = access_token_expires_at
      @client_id         = client_id
      @client_secret     = client_secret
      @endpoint          = endpoint
    end

    def auth_header
      ensure_authentication
      "Bearer #{@access_token}"
    end

    def token_key
      Base64.strict_encode64("#{@client_id}:#{@client_secret}").strip
    end

    def api_request_auth_token
      res = auth_request( { scope: @sid } )

      process_auth_response(res)

      @access_token_expires_at = Time.now.to_i + @expires_in
    end

    def refresh_api_request_auth_token
      res = auth_request( { refresh_token: @refresh_token, scope: @sid}  )

      process_auth_response(res)

      @access_token_expires_at = Time.now.to_i + @expires_in
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

    def auth_request(payload)
      uri = URI("#{@endpoint}/token")
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req["Authorization"] = "Bearer #{token_key}"

        req.set_form_data(payload)
        http.request(req)
      end
    end

    def ensure_authentication
      if @access_token_expires_at.nil?
        puts "NO TOKEN: getting auth token"
        api_request_auth_token
      elsif Time.now.to_i > @access_token_expires_at
        puts "EXPIRED TOKEN: getting auth token"
        api_request_auth_token
      elsif Time.now.to_i > (@access_token_expires_at - REFRESH_TOKEN_LEEWAY)
        puts "TOKEN EXPIRES WITHIN LEEWAY : refresh auth token"
        refresh_api_request_auth_token
      end
    end
  end
end
