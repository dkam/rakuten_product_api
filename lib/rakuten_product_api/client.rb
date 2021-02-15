require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'base64'
require 'nokogiri'

module RakutenProductApi
  class Client
    REFRESH_TOKEN_LEEWAY = 60 * 10 # Ten minutes prior to expiry we should refresh token

    attr_accessor :sid, :username, :password, :consumer_key, :consumer_secret, :mid, :auth_expires_at

    def initialize(sid:             RakutenProductApi.sid,
                   username:        RakutenProductApi.username,
                   password:        RakutenProductApi.password,
                   consumer_key:    RakutenProductApi.consumer_key,
                   consumer_secret: RakutenProductApi.consumer_secret,
                   mid:             RakutenProductApi.mid
                  )

      @sid = sid
      @username = username
      @password = password
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @mid = mid
      
      @auth_expires_at = nil
    end

    def default_params
      @mid.nil? ? {} : {mid: @mid}
    end
    
    def request_auth_token
      Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}").strip
    end
    
    def request_auth_token_header
      "Authorization: Basic #{request_auth_token}"
    end
        
    def api_request_auth
      res = auth_request(
        "https://api.rakutenmarketing.com/token",   
        {grant_type: 'password',username: @username, password: @password, scope: @sid}
      )
      
      process_auth_response(res)
      
      @auth_expires_at = Time.now.to_i + @expires_in
    end
    
    def refresh_api_request_auth
      res = auth_request(
              "https://api.rakutenmarketing.com/token",   
              {grant_type: 'refresh_token',refresh_token: @refresh_token, scope: 'Production'}
            )
      
      process_auth_response(res)

      @auth_expires_at = Time.now.to_i + @expires_in
    end
    
    def process_auth_response(res)
      if res.code == '200'
        doc = JSON.parse(res.body)
        token_type    = doc.dig('token_type')
        @expires_in    = doc.dig('expires_in').to_i     
        @refresh_token = doc.dig('refresh_token')
        @access_token   = doc.dig('access_token')
      else
        puts "RESPONSE CODE #{res.code} received"
        return res
      end
    end

    def auth_request(url, payload)
      uri = URI(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new(uri)
        req['Authorization'] = "Basic #{request_auth_token}"
      
        req.set_form_data(payload)
        http.request(req)
      end
    end
    
    def ensure_authentication
      if @auth_expires_at.nil? 
        puts "NIL: getting auth"
        api_request_auth
      elsif Time.now.to_i > @auth_expires_at
        puts "EXPIRED: getting auth"
        api_request_auth
      elsif Time.now.to_i > ( @auth_expires_at + REFRESH_TOKEN_LEEWAY )
        puts "REFRESH LEEWAY: getting auth"
        refresh_api_request_auth
      else
        puts "VALID AUTH"
      end
    end

    def search(keyword: nil, **options)
      Response.new(api_request(options.merge(keyword: keyword)))
    end

    def api_request(payload)
      ensure_authentication

      params = default_params.merge(payload).map {|k, v| "#{k}=#{v}"}.join("&")
      uri = URI("https://api.rakutenmarketing.com/productsearch/1.0?#{params}")

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Get.new(uri)
        req['Authorization'] = "Bearer #{@access_token}"
        req['Accept'] = "application/xml"

        http.request(req)
      end
      if res.code == '200'
        res
      else
        puts "RESPONSE CODE #{res.code} received"
        return res
      end
    end
  end
end