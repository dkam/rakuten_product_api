# frozen_string_literal: true

require_relative "lib/rakuten_product_api/version"

Gem::Specification.new do |spec|
  spec.name          = "rakuten_product_api"
  spec.version       = RakutenProductApi::VERSION
  spec.authors       = ["Dan Milne"]
  spec.email         = ["d@nmilne.com"]

  spec.summary       = "Client for Rakutenmarketing.com."
  spec.homepage      = "https://github.com/dkam/rakuten_product_api"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/dkam/rakuten_product_api"
  spec.metadata["changelog_uri"] = "https://github.com/dkam/rakuten_product_api/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_runtime_dependency 'nokogiri', '~> 1.13', '>= 1.13.6'
  spec.add_development_dependency "byebug", "~> 11"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
