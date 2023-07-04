module Consulkit
  class RequestOptions

    #
    attr_accessor :query_params

    #
    attr_accessor :body

    #
    attr_accessor :headers

    #
    attr_accessor :open_timeout

    #
    attr_accessor :timeout

    #
    attr_accessor :remaining_options

    #
    def initialize()
      @query_params      = {}
      @body              = nil
      @headers           = {}
      @open_timeout      = nil
      @timeout           = nil
      @remaining_options = {}
    end

    # Create and format headers and params from request options
    #
    # @param opts [Hash]
    #
    def self.from_options(options = {})
      new.update(options)
    end

    def update(options = {})
      options.each_key do |key|
        next unless instance_variable_defined?("@#{key}") && key != 'remaining_options'

        instance_variable_set("@#{key}", options.delete(key))
      end

      @remaining_options = options

      self
    end
  end
end
