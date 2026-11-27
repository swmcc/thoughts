require "rails_helper"

RSpec.describe "OAuth connector flow", type: :request do
  let(:admin) { create(:admin_user) }

  def json = JSON.parse(response.body)

  describe "discovery" do
    it "points the MCP resource at this app as its authorization server" do
      get "/.well-known/oauth-protected-resource"

      expect(json["resource"]).to eq("http://www.example.com/mcp")
      expect(json["authorization_servers"]).to eq([ "http://www.example.com" ])
    end

    it "also serves the path-suffixed protected resource metadata" do
      get "/.well-known/oauth-protected-resource/mcp"
      expect(response).to have_http_status(:ok)
    end

    it "advertises PKCE S256 and dynamic registration" do
      get "/.well-known/oauth-authorization-server"

      expect(json["code_challenge_methods_supported"]).to eq([ "S256" ])
      expect(json["registration_endpoint"]).to eq("http://www.example.com/oauth/register")
    end

    it "uses APP_URL when set" do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with("APP_URL", anything).and_return("https://thoughts.example.org/")

      get "/.well-known/oauth-authorization-server"
      expect(json["issuer"]).to eq("https://thoughts.example.org")
    end
  end

  describe "POST /oauth/register" do
    it "registers a public client" do
      post oauth_register_path, params: { client_name: "Claude", redirect_uris: [ OauthHelpers::REDIRECT_URI ],
                                          token_endpoint_auth_method: "none" }, as: :json

      expect(response).to have_http_status(:created)
      expect(json["client_id"]).to be_present
      expect(json).not_to have_key("client_secret")
    end

    it "issues a secret to confidential clients" do
      post oauth_register_path, params: { client_name: "Claude", redirect_uris: [ OauthHelpers::REDIRECT_URI ],
                                          token_endpoint_auth_method: "client_secret_post" }, as: :json

      expect(json["client_secret"]).to be_present
    end

    it "accepts loopback http redirects for Claude Code" do
      post oauth_register_path, params: { client_name: "Claude Code", redirect_uris: [ "http://localhost:51234/callback" ] }, as: :json
      expect(response).to have_http_status(:created)
    end

    it "rejects non-https, non-loopback redirect URIs" do
      post oauth_register_path, params: { client_name: "Evil", redirect_uris: [ "http://evil.example.com/cb" ] }, as: :json

      expect(response).to have_http_status(:bad_request)
      expect(json["error"]).to eq("invalid_redirect_uri")
    end
  end

  describe "GET /oauth/authorize" do
    let(:client) { register_client }
    let(:challenge) { pkce_pair.last }

    it "refuses unknown redirect URIs without redirecting" do
      get oauth_authorize_path, params: authorize_params(client, challenge, redirect_uri: "https://evil.example.com/cb")
      expect(response).to have_http_status(:bad_request)
    end

    it "requires PKCE" do
      get oauth_authorize_path, params: authorize_params(client, challenge, code_challenge: nil)

      expect(response).to have_http_status(:redirect)
      expect(response.location).to start_with(OauthHelpers::REDIRECT_URI)
      expect(response.location).to include("error=invalid_request")
    end

    it "sends a signed-out admin to login, then back to the consent screen" do
      get oauth_authorize_path, params: authorize_params(client, challenge)
      expect(response).to redirect_to(new_admin_session_path)

      post admin_session_path, params: { email: admin.email, password: "password123" }
      expect(response.location).to include("/oauth/authorize?")

      follow_redirect!
      expect(response.body).to include("Connect Claude?")
    end
  end

  describe "full authorization code exchange" do
    let(:client) { register_client }
    let(:pkce) { pkce_pair }

    before { post admin_session_path, params: { email: admin.email, password: "password123" } }

    def approve(decision: "approve")
      post oauth_authorize_path, params: authorize_params(client, pkce.last).merge(decision: decision)
      Rack::Utils.parse_query(URI.parse(response.location).query)
    end

    def exchange(code, verifier: pkce.first)
      post oauth_token_path, params: { grant_type: "authorization_code", code: code, client_id: client.client_id,
                                       redirect_uri: OauthHelpers::REDIRECT_URI, code_verifier: verifier }
    end

    it "issues tokens that work on /mcp" do
      query = approve
      expect(query["state"]).to eq("xyz")

      exchange(query["code"])
      expect(response).to have_http_status(:ok)
      expect(json).to include("token_type" => "Bearer", "expires_in" => 3600)

      post "/mcp", params: { jsonrpc: "2.0", id: 1, method: "tools/list" }.to_json,
                   headers: { "Authorization" => "Bearer #{json["access_token"]}", "Content-Type" => "application/json" }
      expect(response).to have_http_status(:ok)
    end

    it "returns access_denied when the admin denies" do
      expect(approve(decision: "deny")["error"]).to eq("access_denied")
    end

    it "rejects a wrong PKCE verifier" do
      exchange(approve["code"], verifier: "wrong")
      expect(json["error"]).to eq("invalid_grant")
    end

    it "rejects a reused code" do
      code = approve["code"]
      exchange(code)
      exchange(code)
      expect(json["error"]).to eq("invalid_grant")
    end

    it "rejects an expired code" do
      code = approve["code"]
      travel 11.minutes do
        exchange(code)
      end
      expect(json["error"]).to eq("invalid_grant")
    end

    it "rejects a code issued to another client" do
      code = approve["code"]
      other = register_client(name: "Other")
      post oauth_token_path, params: { grant_type: "authorization_code", code: code, client_id: other.client_id,
                                       redirect_uri: OauthHelpers::REDIRECT_URI, code_verifier: pkce.first }
      expect(json["error"]).to eq("invalid_grant")
    end

    it "rotates refresh tokens and revokes the old pair" do
      exchange(approve["code"])
      first = json

      post oauth_token_path, params: { grant_type: "refresh_token", refresh_token: first["refresh_token"], client_id: client.client_id }
      expect(response).to have_http_status(:ok)
      expect(json["access_token"]).not_to eq(first["access_token"])

      expect(Oauth::AccessToken.authenticate(first["access_token"])).to be_nil

      post oauth_token_path, params: { grant_type: "refresh_token", refresh_token: first["refresh_token"], client_id: client.client_id }
      expect(json["error"]).to eq("invalid_grant")
    end
  end

  describe "POST /oauth/token client authentication" do
    it "requires the secret for confidential clients" do
      client, secret = Oauth::Client.register(client_name: "Claude", redirect_uris: [ OauthHelpers::REDIRECT_URI ], confidential: true)

      post oauth_token_path, params: { grant_type: "refresh_token", refresh_token: "x", client_id: client.client_id }
      expect(response).to have_http_status(:unauthorized)

      basic = Base64.strict_encode64("#{client.client_id}:#{secret}")
      post oauth_token_path, params: { grant_type: "refresh_token", refresh_token: "x" },
                             headers: { "Authorization" => "Basic #{basic}" }
      expect(json["error"]).to eq("invalid_grant")
    end

    it "rejects unsupported grant types" do
      client = register_client
      post oauth_token_path, params: { grant_type: "password", client_id: client.client_id }
      expect(json["error"]).to eq("unsupported_grant_type")
    end
  end
end
