class AdminUser < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_create :generate_api_token

  def regenerate_api_token!
    update!(api_token: generate_token)
  end

  private

  def generate_api_token
    self.api_token ||= generate_token
  end

  def generate_token
    SecureRandom.hex(32)
  end
end
