module Oauth
  class AuthorizationCode < ApplicationRecord
    LIFETIME = 10.minutes

    belongs_to :client, class_name: "Oauth::Client", foreign_key: :oauth_client_id, inverse_of: :authorization_codes
    belongs_to :admin_user

    # Returns the raw code; only its digest is stored.
    def self.issue(client:, admin_user:, redirect_uri:, code_challenge:)
      raw = Oauth.generate_secret
      create!(client: client, admin_user: admin_user, redirect_uri: redirect_uri,
              code_challenge: code_challenge, code_digest: Oauth.digest(raw),
              expires_at: LIFETIME.from_now)
      raw
    end

    # Single use: returns the code record, or nil if anything doesn't match.
    def self.redeem(raw, client:, redirect_uri:, code_verifier:)
      transaction do
        code = lock.find_by(code_digest: Oauth.digest(raw), oauth_client_id: client.id)
        return nil if code.nil? || code.used_at.present? || code.expires_at.past?

        code.update!(used_at: Time.current)
        return nil unless code.redirect_uri == redirect_uri.to_s && code.pkce_matches?(code_verifier)

        code
      end
    end

    def pkce_matches?(verifier)
      return false if verifier.blank?

      computed = Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
      ActiveSupport::SecurityUtils.secure_compare(computed, code_challenge)
    end
  end
end
