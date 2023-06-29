# frozen_string_literal: true

module Consulkit
  class Client
    module KV
      def kv_read(key, query_params = {})
        get("/v1/kv/#{key}", query_params).body
      end

      def kv_read_recursive(key, query_params = {})
        kv_read(key, query_params.merge({ recurse: true }))
      end

      def kv_put(key, value, query_params = {})
        put("/v1/kv/#{key}", value, query_params).body == true
      end

      def kv_delete(key, query_params = {})
        delete("/v1/kv/#{key}", query_params).body == true
      end
    end
  end
end
