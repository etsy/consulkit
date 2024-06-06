# frozen_string_literal: true

require 'consulkit/configurable'
require 'consulkit/client/health'
require 'consulkit/client/kv'
require 'consulkit/client/session'

module Consulkit
  # Client for the Consul API.
  class Client

    include Consulkit::Configurable
    include Consulkit::Client::Health
    include Consulkit::Client::KV
    include Consulkit::Client::Session

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

    def camel_case_keys(hash)
      hash.transform_keys { |k| k.to_s.split('_').collect(&:capitalize).join }
    end

  end
end
