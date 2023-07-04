# frozen_string_literal: true

module Consulkit
  class Client
    # Methods for accessing Consul's KV store.
    module KV

      # Reads the specified key.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/kv#read-key
      #
      # @param key [String] the key to read.
      # @param query_params [Hash] Optional query parameters.
      # @param query_params [Boolean] :recurse
      # @param query_params [Boolean] :raw
      # @param query_params [Boolean] :keys
      # @param query_params [String] :separator
      #
      # @raise [Consulkit::Error::NotFound] if the key does not exist.
      #
      # @yield [Faraday::Response] The response from the underlying Faraday library.
      #
      # @return [Array<Hash>]
      def kv_read!(key, query_params = {})
        response = get("/v1/kv/#{key}", query_params)

        if block_given?
          yield response
        else
          response.body
        end
      end

      # Reads the specified key.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/kv#read-key
      #
      # @param key [String] the key to read.
      # @param query_params [Hash] Optional query parameters.
      # @param query_params [Boolean] :recurse
      # @param query_params [Boolean] :raw
      # @param query_params [Boolean] :keys
      # @param query_params [String] :separator
      #
      # @yield [Faraday::Response] The response from the underlying Faraday library.
      #
      # @return [Array<Hash>]
      def kv_read(key, query_params = {}, &block)
        kv_read!(key, query_params, &block)
      rescue Consulkit::Error::NotFound
        []
      end

      # Reads the specified key, and returns the X-Consul-Index value.
      #
      # @see kv_read
      #
      # @param key [String] the key to read.
      # @param query_params [Hash] Optional query parameters.
      #
      # @return [Array<(Integer, Array<Hash>)>]
      def kv_read_with_index(key, query_params = {})
        kv_read!(key, **query_params) do |response|
          [response.headers['X-Consul-Index'], response.body]
        end
      rescue Consulkit::Error::NotFound => e
        [e.response_headers['X-Consul-Index'], []]
      end

      # Reads the specified key, then yields the result of a blocking query for that key. Return false to end
      # the loop.
      #
      # @see kv_read
      #
      # @param key [String] the key to read.
      # @param query_params [Hash] Optional query parameters.
      #
      # @yield [changed, result]
      # @yieldparam changed [Boolean] true if the consul index has changed since the last query.
      # @yieldparam result [Array<Hash>] the current result of the consul query.
      def kv_read_blocking(key, wait = nil, query_params = {})
        last_index, = kv_read_with_index(key, query_params)

        loop do
          new_index, result = kv_read_with_index(key, **query_params, wait: wait, index: last_index)

          return unless yield(new_index != last_index, result)
        end
      end

      # Reads the specified key recursively.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/kv#read-key
      #
      # @param key [String] the key to read.
      # @param query_params [Hash] Optional query parameters.
      #
      # @return [Array<Hash>]
      def kv_read_recursive(key, query_params = {})
        kv_read(key, **query_params, recurse: true)
      end

      # Reads the specified key recursively, returning a hash where the each key is indexed by its key name.
      #
      # @param key [String] the key to read.
      #
      # @return [Hash<String, Hash>]
      def kv_read_recursive_as_hash(key)
        kv_read_recursive(key).to_h do |entry|
          [entry['Key'], entry]
        end
      end

      # Creates or updates the specified key.
      #
      # @see https://developer.hashicorp.com/consul/api-docs/kv#create-update-key
      # @see kv_write_cas
      # @see kv_acquire_lock
      # @see kv_release_lock
      #
      # @param key [String] the key to create or update.
      # @param query_params [Hash] Optional query parameters.
      # @param query_params [Integer] :flags
      # @param query_params [Integer] :cas
      # @param query_params [String] :acquire
      # @param query_params [String] :release
      #
      # @yield [Faraday::Response] The response from the underlying Faraday library.
      #
      # @return [Boolean]
      def kv_write(key, value, query_params = {})
        response = put("/v1/kv/#{key}", value, query_params)

        if block_given?
          yield response
        else
          response.body == true
        end
      end

      # Atomically creates or updates the specified key, if and only if the modify index matches.
      #
      # @param key [String] the key to create or update.
      # @param query_params [Hash] Optional query parameters.
      #
      # return [Boolean]
      def kv_write_cas(key, value, modify_index, query_params = {})
        kv_write(key, value, **query_params, cas: modify_index)
      end

      # Atomically creates or updates the specified key by acquiring a lock with the session ID.
      #
      # @param key [String] the key to create or update.
      # @param query_params [Hash] Optional query parameters.
      #
      # return [Boolean]
      def kv_acquire_lock(key, session_id, value = nil, query_params = {})
        kv_write(key, value, **query_params, acquire: session_id)
      end

      # Atomically updates the specified key while releasing the associated lock.
      #
      # @param key [String] the key to update.
      # @param query_params [Hash] Optional query parameters.
      #
      # return [Boolean]
      def kv_release_lock(key, session_id, value = nil, query_params = {})
        kv_write(key, value, **query_params, release: session_id)
      end

      # Deletes the specified key.
      #
      # @param key [String] the key to delete.
      # @param query_params [Hash] Optional query parameters.
      #
      # return [Boolean]
      def kv_delete(key, query_params = {})
        delete("/v1/kv/#{key}", query_params).body == true
      end

    end
  end
end
