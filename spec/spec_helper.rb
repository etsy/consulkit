# frozen_string_literal: true

require 'consulkit'
require 'rspec'
require 'vcr'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'

  config.configure_rspec_metadata!
  config.hook_into :webmock

  record_mode =
    if ENV['CONSULKIT_TEST_VCR_RECORD']
      :new_episodes
    elsif ENV['CONSULKIT_TEST_VCR_RECORD_ALL']
      :all
    else
      :none
    end

  config.default_cassette_options = {
    record: record_mode,
  }
end
