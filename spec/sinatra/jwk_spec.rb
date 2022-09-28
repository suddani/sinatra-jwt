# frozen_string_literal: true

require_relative "../fixtures/sample_app_jwk"

RSpec.describe Sinatra::Jwt::JwkLoader do
  include Rack::Test::Methods

  def unauthorized(message)
    { status: "Unauthorized", message: message }.to_json
  end

  def jwt(payload = {}, kid: nil)
    JWT.encode payload, secret_key, algorithm, kid.nil? ? {} : { kid: kid }
  end

  def bearer(payload = {}, kid: nil)
    "Bearer #{jwt(payload, kid: kid || used_kid)}"
  end

  def app
    SampleAppJwk
  end

  let(:used_kid) { "lol" }
  let(:secret_key) { "superSecretKeyJWK" }
  let(:algorithm) { "HS512" }

  it "returns empty response" do
    get "/"
    expect(last_response.body).to eq("Hello World")
    expect(last_response.status).to eq 200
  end

  it "jwt missing" do
    get "/protected"
    expect(last_response.body).to eq unauthorized "Missing JWT"
    expect(last_response.status).to eq 401
  end

  it "jwt correctly set" do
    header "Authorization", bearer
    get "/protected"
    expect(last_response.body).to eq "loggedIn"
    expect(last_response.status).to eq 200
  end

  context "key not found" do
    let(:used_kid) { "other" }
    it "jwt correctly set" do
      header "Authorization", bearer
      get "/protected"
      expect(last_response.body).to eq unauthorized "Could not find public key for kid other"
      expect(last_response.status).to eq 401
    end
  end

  it "jwt missing rights" do
    header "Authorization", bearer
    get "/protected/rights"
    expect(last_response.body).to eq unauthorized "Missing rights"
    expect(last_response.status).to eq 401
  end

  it "jwt contains rights" do
    header "Authorization", bearer({ rights: ["read_api"] })
    get "/protected/rights"
    expect(last_response.body).to eq "loggedIn"
    expect(last_response.status).to eq 200
  end

  it "jwt contains more rights" do
    header "Authorization", bearer({ rights: %w[write_api read_api] })
    get "/protected/rights"
    expect(last_response.body).to eq "loggedIn"
    expect(last_response.status).to eq 200
  end

  it "jwt contains different rights" do
    header "Authorization", bearer({ rights: ["write_api"] })
    get "/protected/rights"
    expect(last_response.body).to eq unauthorized "Missing rights"
    expect(last_response.status).to eq 401
  end

  it "jwt contains different rights" do
    header "Authorization", bearer({ rights: { api: "write" } })
    get "/protected/rights"
    expect(last_response.body).to eq unauthorized "Missing rights"
    expect(last_response.status).to eq 401
  end

  it "jwt contains rights and other things" do
    header "Authorization", bearer({ rights: ["read_api"], username: "test" })
    get "/protected/rights"
    expect(last_response.body).to eq "loggedIn"
    expect(last_response.status).to eq 200
  end

  it "jwt correctly set" do
    header "Authorization", bearer
    get "/protected/next"
    expect(last_response.body).to eq "loggedIn"
    expect(last_response.status).to eq 200
  end

  it "jwt next" do
    get "/protected/next"
    expect(last_response.body).to eq "loggedOut"
    expect(last_response.status).to eq 200
  end

  it "jwt rights next write" do
    header "Authorization", bearer({ rights: ["write_api"] })
    get "/protected/rights/next"
    expect(last_response.body).to eq "writeAccess"
    expect(last_response.status).to eq 200
  end

  it "jwt rights next read" do
    header "Authorization", bearer({ rights: ["read_api"] })
    get "/protected/rights/next"
    expect(last_response.body).to eq "readAccess"
    expect(last_response.status).to eq 200
  end

  it "jwt rights next access" do
    header "Authorization", bearer
    get "/protected/rights/next"
    expect(last_response.body).to eq "access"
    expect(last_response.status).to eq 200
  end

  it "jwt rights next access" do
    get "/protected/rights/next"
    expect(last_response.body).to eq unauthorized "Missing JWT"
    expect(last_response.status).to eq 401
  end
end
