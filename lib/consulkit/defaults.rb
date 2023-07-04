# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'
require 'consulkit/middleware/raise_error'

module Consulkit
  # Default configuration options for the {Consulkit} singleton and individual {Client} instances.
  module Defaults

    HTTP_ADDR = 'http://localhost:8500'

    HTTP_TOKEN = nil

    MIDDLEWARE = Faraday::RackBuilder.new do |builder|
      retry_exceptions = Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Consulkit::Error::Server]

      builder.use(Faraday::Request::Json)
      builder.use(Faraday::Response::Json)
      builder.use(Faraday::Retry::Middleware, exceptions: retry_exceptions)
      builder.use(Consulkit::Middleware::RaiseError)

      builder.adapter Faraday.default_adapter
    end

    class << self

      def connection_options
        {}
      end

      def http_addr
        ENV.fetch('CONSUL_HTTP_ADDR', HTTP_ADDR)
      end

      def http_token
        ENV.fetch('CONSUL_HTTP_TOKEN', HTTP_TOKEN)
      end

      def middleware
        MIDDLEWARE
      end

    end

  end
end
