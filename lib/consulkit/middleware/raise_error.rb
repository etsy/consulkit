# frozen_string_literal: true

require 'consulkit/error'

module Consulkit
  module Middleware
    # This class raises a Consulkit-flavored exception based on the HTTP status codes returned by
    # the API.
    class RaiseError < Faraday::Middleware
      def on_complete(response)
        return unless (error = Consulkit::Error.from_response(response))

        raise error
      end
    end
  end
end
