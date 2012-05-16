require 'faraday'

# @private
module FaradayMiddleware
  # @private
  class OAuth2 < Faraday::Middleware
    def call(env)

      if env[:method] == :get or env[:method] == :delete
        env[:url].query = {} if env[:url].query.nil?

        if @access_token and not env[:url].query["client_secret"]
          env[:url].query = env[:url].query.merge(:access_token => @access_token)
          env[:request_headers] = env[:request_headers].merge('Authorization' => "Token token=\"#{@access_token}\"")
        elsif @client_id
          env[:url].query = env[:url].query.merge(:client_id => @client_id)
        end
      else
        if @access_token and not env[:body] && env[:body][:client_secret]
          env[:body] = {} if env[:body].nil?
          env[:body] = env[:body].merge(:access_token => @access_token)
          env[:request_headers] = env[:request_headers].merge('Authorization' => "Token token=\"#{@access_token}\"")
        elsif @client_id
          env[:body] = env[:body].merge(:client_id => @client_id)
        end
      end

      env[:url].query = nil if env[:url].query == {}

      @app.call env
    end

    def initialize(app, client_id, access_token=nil)
      @app = app
      @client_id = client_id
      @access_token = access_token
    end
  end
end
