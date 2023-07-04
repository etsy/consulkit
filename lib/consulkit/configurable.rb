# frozen_string_literal: true

module Consulkit
  # Configuration options for the {Consulkit} singleton and individual {Client} instances.
  module Configurable

    # [String] the HTTP(s) address to use to connect to Consul
    attr_accessor :http_addr

    # [String] the ACL token used for authentication
    attr_writer :http_token

    # [Hash] Faraday connection options
    attr_accessor :connection_options

    # [Faraday::RackBuilder] middleware for Faraday
    attr_accessor :middleware

    CONFIGURABLE_KEYS = %i[
      connection_options
      http_addr
      http_token
      middleware
    ].freeze

    def setup!
      CONFIGURABLE_KEYS.each do |key|
        instance_variable_set(:"@#{key}", Consulkit::Defaults.send(key))
      end

      self
    end

    def options
      CONFIGURABLE_KEYS.to_h { |key| [key, instance_variable_get("@#{key}")] }
    end

  end
end
