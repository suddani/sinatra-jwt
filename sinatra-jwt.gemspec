# frozen_string_literal: true

require_relative "lib/sinatra/jwt/version"

Gem::Specification.new do |spec|
  spec.name = "sinatra-jwt"
  spec.version = Sinatra::Jwt::VERSION
  spec.authors = ["Daniel Sudmann"]
  spec.email = ["suddani@gmail.com"]

  spec.summary = "Simple package to handle jwt auth in Sinatra"
  spec.homepage = "https://github.com/suddani/sinatra-jwt"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/suddani/sinatra-jwt"
  spec.metadata["changelog_uri"] = "https://github.com/suddani/sinatra-jwt/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "jwt", "~> 2.5"
  spec.add_dependency "sinatra", "~> 2.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
