module Oauth
  class Client < ApplicationRecord
    has_many :authorization_codes, foreign_key: :oauth_client_id, inverse_of: :client, dependent: :delete_all
    has_many :access_tokens, foreign_key: :oauth_client_id, inverse_of: :client, dependent: :delete_all

    validates :client_id, presence: true, uniqueness: true
    validates :client_name, presence: true, length: { maximum: 100 }
    validate :redirect_uris_are_safe

    before_validation :generate_client_id, on: :create

    # Returns [client, raw_secret]; raw_secret is nil for public (PKCE-only) clients.
    def self.register(client_name:, redirect_uris:, confidential: false)
      secret = Oauth.generate_secret if confidential
      client = new(client_name: client_name.presence || "MCP client",
                   redirect_uris: Array(redirect_uris).map(&:to_s),
                   client_secret_digest: secret && Oauth.digest(secret))
      client.save
      [ client, secret ]
    end

    # https anywhere, or http only on loopback (Claude Code's local callback).
    def self.safe_redirect_uri?(uri)
      parsed = URI.parse(uri)
      return false if parsed.host.blank? || parsed.fragment.present?

      parsed.scheme == "https" ||
        (parsed.scheme == "http" && %w[localhost 127.0.0.1 [::1] ::1].include?(parsed.host))
    rescue URI::InvalidURIError
      false
    end

    def confidential?
      client_secret_digest.present?
    end

    def valid_secret?(secret)
      return true unless confidential?

      secret.present? && ActiveSupport::SecurityUtils.secure_compare(client_secret_digest, Oauth.digest(secret))
    end

    def redirect_uri_allowed?(uri)
      redirect_uris.include?(uri.to_s)
    end

    private

    def generate_client_id
      self.client_id ||= SecureRandom.uuid
    end

    def redirect_uris_are_safe
      if redirect_uris.blank?
        errors.add(:redirect_uris, "can't be blank")
        return
      end

      redirect_uris.each do |uri|
        errors.add(:redirect_uris, "#{uri} is not allowed") unless self.class.safe_redirect_uri?(uri)
      end
    end
  end
end
