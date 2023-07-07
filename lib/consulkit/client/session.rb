# frozen_string_literal: true

module Consulkit
  class Client
    # Methods for creating, deleting, and querying sessions.
    module Session

      # Creates a session.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/session#create-session
      #
      # @example Create a session with a 60 second TTL and the 'delete' behavior.
      #   session_create(ttl: "60s", behavior: 'delete')
      #
      # @param session_opts [Hash] options to create the session with.
      # @option session_opts [String] :lock_delay
      # @option session_opts [String] :node
      # @option session_opts [String] :name
      # @option session_opts [Array<String>] :node_checks
      # @option session_opts [Array<Hash>] :service_checks
      # @option session_opts [String] :behavior
      # @option session_opts [String] :ttl
      #
      # @return String the ID of the created session.
      def session_create(session_opts = {})
        put('/v1/session/create', camel_case_keys(session_opts)).body['ID']
      end

      # Deletes a session.
      #
      # @param session_id [String] the ID of the session to delete.
      #
      # @return [Boolean]
      def session_delete(session_id)
        put("/v1/session/destroy/#{session_id}").body == true
      end

      # Reads a session.
      #
      # @param session_id [String] the ID of the session to read.
      #
      # @return [Hash]
      def session_read(session_id)
        get("/v1/session/info/#{session_id}").body.first
      end

      # Renews a session.
      #
      # @param session_id [String] the ID of the session to renew.
      #
      # @return [Hash]
      def session_renew(session_id)
        put("/v1/session/renew/#{session_id}").body.first
      end

    end
  end
end
