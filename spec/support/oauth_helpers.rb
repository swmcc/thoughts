module OauthHelpers
  REDIRECT_URI = "https://claude.ai/api/mcp/auth_callback".freeze

  def pkce_pair
    verifier = SecureRandom.urlsafe_base64(48)
    challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    [ verifier, challenge ]
  end

  def authorize_params(client, challenge, overrides = {})
    {
      client_id: client.client_id, redirect_uri: REDIRECT_URI, response_type: "code",
      state: "xyz", code_challenge: challenge, code_challenge_method: "S256"
    }.merge(overrides)
  end

  def register_client(name: "Claude")
    Oauth::Client.register(client_name: name, redirect_uris: [ REDIRECT_URI ]).first
  end

  def issue_access_token(client: register_client, admin_user: create(:admin_user))
    Oauth::AccessToken.issue(client: client, admin_user: admin_user)[:access_token]
  end
end

RSpec.configure do |config|
  config.include OauthHelpers
  config.include ActiveSupport::Testing::TimeHelpers
end
