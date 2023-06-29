# frozen_string_literal: true

require 'consulkit/configurable'
require 'consulkit/client/kv'

module Consulkit
  class Client
    include Consulkit::Configurable
    include Consulkit::Client::KV

    def initialize(options = {})
      CONFIGURABLE_KEYS.each do |key|
        value = options[key].nil? ? Consulkit.instance_variable_get("@#{key}") : options[key]

        instance_variable_set("@#{key}", value)
      end
    end

    def delete(url, query_params = {})
      request(:delete, url, query_params, nil)
    end

    def get(url, query_params = {})
      request(:get, url, query_params, nil)
    end

    def post(url, body = nil, query_params = {})
      request(:post, url, query_params, body)
    end

    def put(url, body = nil, query_params = {})
      request(:put, url, query_params, body)
    end

    def request(method, url, query_params, body)
      http.run_request(method, url, body, nil) do |request|
        request.params.update(query_params) if query_params
      end
    end

    def http
      opts = @connection_options

      opts['builder'] = @middleware.dup if middleware

      opts['request'] ||= {}
      opts['request']['params_encoder'] = Faraday::FlatParamsEncoder

      opts['headers'] ||= {}
      opts['headers']['Authorization'] = "Bearer #{http_token}" if @http_token

      @http ||= Faraday.new(http_addr, opts)
    end
  end
end
