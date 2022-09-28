# frozen_string_literal: true

require "rack/test"

require "simplecov"
SimpleCov.start do
  SimpleCov.minimum_coverage 90
end

require "sinatra/jwt"

RSpec.configure do |config|
  # config.include Rack::Test::Methods

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
