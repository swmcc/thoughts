# Minimal OAuth 2.1 authorization server for the MCP connector: dynamic
# client registration, authorization code + PKCE (S256), refresh rotation.
# Tokens are random and stored only as SHA-256 digests.
module Oauth
  def self.table_name_prefix
    "oauth_"
  end

  def self.digest(value)
    Digest::SHA256.hexdigest(value.to_s)
  end

  def self.generate_secret
    SecureRandom.urlsafe_base64(32)
  end
end
