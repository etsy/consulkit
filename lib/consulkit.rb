# frozen_string_literal: true

require 'consulkit/client'
require 'consulkit/configurable'
require 'consulkit/defaults'

module Consulkit
  class << self
    include Consulkit::Configurable

    def client
      Consulkit::Client.new(options)
    end
  end
end

Consulkit.setup!
