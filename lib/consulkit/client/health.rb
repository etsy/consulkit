# frozen_string_literal: true

module Consulkit
  class Client
    # Methods for querying health checks registered with Consul.
    module Health

      # Returns the list of service instances providing the given service, including health check
      # information.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/health#list-service-instances-for-service
      #
      # @param key [String] the key to read.
      # @option query_params [Hash] optional query parameters.
      # @option query_params [Boolean] :passing
      # @option query_params [String] :filter
      #
      # @yield [Faraday::Response] The response from the underlying Faraday library.
      #
      # @return [Array<Hash>]
      def health_list_service_instances(service, query_params = {})
        response = get("/v1/health/service/#{service}", query_params)

        if block_given?
          yield response
        else
          response.body
        end
      end

    end
  end
end
