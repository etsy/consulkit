# frozen_string_literal: true

require 'consulkit/client'
require 'consulkit/configurable'
require 'consulkit/defaults'
require 'consulkit/semaphore_coordinator'
require 'consulkit/version'

# Ruby toolkit for the Consul API.
#
# @see https://developer.hashicorp.com/consul/api-docs
module Consulkit

  class << self

    include Consulkit::Configurable

    def client
      Consulkit::Client.new(options)
    end

    def semaphore_coordinator(key_prefix, client: nil, logger: nil)
      Consulkit::SemaphoreCoordinator.new(client || self.client, key_prefix, logger)
    end

  end

end

Consulkit.setup!
