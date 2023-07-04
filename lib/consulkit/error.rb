# frozen_string_literal: true

module Consulkit
  # An error returned from the Consul API.
  class Error < StandardError

    def initialize(response)
      @response = response

      super(error_message)
    end

    def response_status
      @response.status
    end

    def response_headers
      @response.response_headers
    end

    def response_body
      @response.response_body
    end

    private

    def error_message
      @response.instance_eval do
        msg = "#{method.to_s.upcase} #{url}: #{status} #{reason_phrase}"
        msg << " - #{body}" if body

        msg
      end
    end

    class Client < Error; end

    class BadRequest < Client; end

    class Forbidden < Client; end

    class ACLNotFound < Forbidden; end

    class NotFound < Client; end

    class Server < Error; end

    # Returns the appropriate Consulkit::Error subclass based on the status and
    # response message, or nil if the response is not an error.
    #
    # @param [Hash] response the HTTP response
    #
    # @return Consulkit::Error
    private_class_method def self.from_response(response)
      return unless (error_class = error_class_for(response))

      error_class.new(response)
    end

    # @private
    private_class_method def self.error_class_for(response)
      status = response[:status].to_i
      body   = response[:body].to_s

      case status
      when 400 then BadRequest
      when 403 then error_class_for_http403(body)
      when 404 then NotFound

      when 400..499 then Client
      when 500..599 then Server
      end
    end

    # @private
    private_class_method def self.error_class_for_http403(body)
      case body
      when /acl not found/i then ACLNotFound
      else Forbidden
      end
    end

  end
end
