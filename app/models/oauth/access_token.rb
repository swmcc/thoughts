module Oauth
  class AccessToken < ApplicationRecord
    LIFETIME = 1.hour
    REFRESH_LIFETIME = 90.days

    belongs_to :client, class_name: "Oauth::Client", foreign_key: :oauth_client_id, inverse_of: :access_tokens
    belongs_to :admin_user

    scope :active, -> { where(revoked_at: nil).where("expires_at > ?", Time.current) }

    # Returns the token response hash with raw values; only digests are stored.
    def self.issue(client:, admin_user:)
      access = Oauth.generate_secret
      refresh = Oauth.generate_secret
      create!(client: client, admin_user: admin_user,
              token_digest: Oauth.digest(access), refresh_token_digest: Oauth.digest(refresh),
              expires_at: LIFETIME.from_now, refresh_expires_at: REFRESH_LIFETIME.from_now)

      { access_token: access, token_type: "Bearer", expires_in: LIFETIME.to_i, refresh_token: refresh }
    end

    def self.authenticate(raw)
      return nil if raw.blank?

      active.includes(:client, :admin_user).find_by(token_digest: Oauth.digest(raw))
    end

    # Rotates: the old token pair is revoked and a new one issued.
    def self.refresh(raw_refresh, client:)
      transaction do
        token = lock.find_by(refresh_token_digest: Oauth.digest(raw_refresh), oauth_client_id: client.id)
        return nil if token.nil? || token.revoked_at.present? || token.refresh_expires_at.past?

        token.update!(revoked_at: Time.current)
        issue(client: client, admin_user: token.admin_user)
      end
    end
  end
end
