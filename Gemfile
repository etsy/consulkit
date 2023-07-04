# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

gem 'faraday', '~> 2.7'
gem 'faraday-retry'
gem 'rake', '~> 13.0'

group :test do
  gem 'rspec', '~> 3.0'
end

group :development do
  gem 'yard'
end

group :test, :development do
  gem 'bundler', '~> 2.3'
  gem 'rubocop', '~> 1.21'
end
