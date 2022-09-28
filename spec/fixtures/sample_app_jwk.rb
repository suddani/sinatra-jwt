# frozen_string_literal: true

class SampleAppJwk < Sinatra::Base
  register Sinatra::Jwt

  jwk_file "spec/fixtures/jwk.json"
  jwt_data_contains_diff Sinatra::Jwt::TopLevelKeyArrayDiff

  get "/" do
    "Hello World"
  end

  get "/noauth", auth: false do
    "loggedIn"
  end

  get "/protected", auth: true do
    "loggedIn"
  end

  get "/protected/rights", auth: [{ contains: { rights: ["read_api"] } }] do
    "loggedIn"
  end

  get "/protected/next", auth: [{ next: true }] do
    "loggedIn"
  end

  get "/protected/next" do
    "loggedOut"
  end

  get "/protected/rights/next", auth: [{ contains: { rights: ["write_api"] }, next: true }] do
    "writeAccess"
  end

  get "/protected/rights/next", auth: [{ contains: { rights: ["read_api"] }, next: true }] do
    "readAccess"
  end

  get "/protected/rights/next", auth: true do
    "access"
  end
end
