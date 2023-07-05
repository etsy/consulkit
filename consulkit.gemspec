# frozen_string_literal: true

require_relative 'lib/consulkit/version'

Gem::Specification.new do |spec|
  spec.name    = 'consulkit'
  spec.version = Consulkit::VERSION
  spec.authors = ['Eric Norris']
  spec.email   = ['enorris@etsy.com']

  spec.summary  = 'Ruby toolkit for the Consul API'
  spec.homepage = 'https://github.com/ericnorris/consulkit'

  spec.license = 'MIT'

  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 2.7'
  spec.add_runtime_dependency 'faraday-retry', '~> 2.2'
end
