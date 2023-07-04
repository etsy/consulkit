# frozen_string_literal: true

module Consulkit
  # Coordinates the usage of a consul key as distributed semaphore, following the algorithm described by Hashicorp
  # [here](https://developer.hashicorp.com/consul/tutorials/developer-configuration/distributed-semaphore).
  class SemaphoreCoordinator

    # Initializes the coordinater using the given Consulkit client and key prefix.
    #
    # @param client [Consulkit::Client] the client to use.
    # @param key_prefix [String] the key_prefix to use.
    # @param logger [Logger] if non-nil, will log during semaphore operations.
    def initialize(client, key_prefix, logger = nil)
      @client     = client
      @key_prefix = key_prefix
      @logger     = logger || Logger.new(IO::NULL)
    end

    # Continually attempts to acquire the semaphore until successful using exponential backoff.
    #
    # @see Consulkit::Client.session_create
    #
    # @param session_id [String] the ID of a consul session to associate with the semaphore.
    # @param limit [Integer] the maximum number of holders for the semaphore.
    # @param backoff_cap [Float] the maximum interval to wait between attempts.
    # @param timeout [Float] the maximum number of seconds to sleep before giving up; nil means try forever.
    #
    # @return [Boolean]
    def acquire(session_id, limit, backoff_cap: 10.0, timeout: nil)
      exponential_backoff(backoff_cap, timeout) do
        @logger.info(%(calling try_acquire("#{session_id}", #{limit})))

        try_acquire(session_id, limit)
      end
    end

    # Continually attempts to release the semaphore until successful using exponential backoff.
    #
    # @param session_id [String] the ID of a consul session to associate with the semaphore.
    # @param backoff_cap [Float] the maximum interval to wait between attempts.
    # @param timeout [Float] the maximum number of seconds to sleep before giving up; nil means try forever.
    #
    # @return [Boolean]
    def release(session_id, backoff_cap: 10.0, timeout: nil)
      exponential_backoff(backoff_cap, timeout) do
        @logger.info(%(calling try_release("#{session_id}")))

        try_release(session_id)
      end
    end

    # Attempts to acquire the semaphore, allowing up to the given limit of holders.
    #
    # @see Consulkit::Client.session_create
    #
    # @param session_id [String] the ID of a consul session to associate with the semaphore.
    # @param limit [Integer] the maximum number of holders for the semaphore.
    #
    # @return [Boolean]
    def try_acquire(session_id, limit)
      raise ArgumentError, 'semaphore limit must be at least 1' if limit < 1

      read!

      return true if @holders.include? session_id

      unless @contenders.include? session_id
        return false unless @client.kv_acquire_lock("#{@key_prefix}/#{session_id}", session_id)

        @contenders << session_id
      end

      return false if @holders.size >= limit

      @logger.info("semaphore has less than #{limit} holders, attempting to grab")

      write_coordination_key(@holders.dup.add(session_id))
    end

    # Attempts to release the semaphore.
    #
    # @param session_id [String] the ID of a consul session to associate with the semaphore.
    #
    # @return [Boolean]
    def try_release(session_id)
      read!

      return true unless @holders.include? session_id

      if @contenders.include? session_id
        @client.kv_delete("#{@key_prefix}/#{session_id}")
        @contenders.delete(session_id)
      end

      write_coordination_key(@holders.dup.delete(session_id))
    end

    private

    # Executes a block using [exponential backoff with jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/).
    #
    # @param backoff_cap [Float] the maximum interval to wait between attempts.
    # @param timeout [Float] the maximum number of seconds to sleep before giving up; nil means try forever.
    #
    # @yieldreturn [Boolean]
    #
    # @return [Boolean]
    def exponential_backoff(backoff_cap, timeout)
      raise ArgumentError, 'backoff_cap must be at least 1.0' if backoff_cap < 1

      # start with 200ms backoff
      current_backoff = 0.2
      elapsed_time    = 0

      loop do
        return true if yield

        if !timeout.nil? && elapsed_time > timeout
          @logger.info('timeout exceeded')

          return false
        end

        # sleep up to the current_backoff value
        time_to_sleep = rand(0..current_backoff)

        @logger.info("call failed, will sleep #{time_to_sleep.truncate(3)} seconds until trying again")

        sleep time_to_sleep

        elapsed_time   += time_to_sleep
        current_backoff = [2 * current_backoff, backoff_cap].min
      end
    end

    # Reads the semaphore data from the key prefix.
    def read!
      @logger.info("reading semaphore @ key prefix '#{@key_prefix}'")

      @modify_index   = 0
      @contenders     = Set[]
      claimed_holders = Set[]

      @client.kv_read_recursive(@key_prefix).each do |entry|
        if entry['Key'] == coordination_key_name
          @modify_index   = entry['ModifyIndex']
          claimed_holders = parse_holders(entry['Value'])
        elsif entry['Session']
          @contenders << entry['Session']
        end
      end

      @holders = claimed_holders & @contenders
    end

    # Returns the expected name of the coordination key.
    def coordination_key_name
      "#{@key_prefix}/.lock"
    end

    # Parses the list of claimed semaphore holders.
    def parse_holders(value)
      Set.new(JSON.parse(Base64.decode64(value)))
    rescue JSON::ParseError, ArgumentError
      Set[]
    end

    # Attempts to write the coordination key with the optional new list of holders.
    #
    # @param new_holders [Set<String>] an optional new list of holders.
    #
    # @return [Boolean]
    def write_coordination_key(new_holders = @holders)
      if @client.kv_write_cas(coordination_key_name, JSON.generate(new_holders.to_a), @modify_index)
        @holders = new_holders

        return true
      end

      false
    end

  end
end
