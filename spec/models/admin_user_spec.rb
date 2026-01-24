require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      admin = build(:admin_user)
      expect(admin).to be_valid
    end

    it "requires email to be present" do
      admin = build(:admin_user, email: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("can't be blank")
    end

    it "requires email to be unique" do
      create(:admin_user, email: "admin@example.com")
      admin = build(:admin_user, email: "admin@example.com")
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("has already been taken")
    end

    it "requires email to be valid format" do
      admin = build(:admin_user, email: "not-an-email")
      expect(admin).not_to be_valid
      expect(admin.errors[:email]).to include("is invalid")
    end

    it "requires password to be present" do
      admin = build(:admin_user, password: nil, password_confirmation: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:password]).to include("can't be blank")
    end
  end

  describe "has_secure_password" do
    it "authenticates with correct password" do
      admin = create(:admin_user, password: "secret123", password_confirmation: "secret123")
      expect(admin.authenticate("secret123")).to eq(admin)
    end

    it "does not authenticate with incorrect password" do
      admin = create(:admin_user, password: "secret123", password_confirmation: "secret123")
      expect(admin.authenticate("wrong")).to be_falsey
    end
  end

  describe "api_token" do
    it "generates an api_token on create" do
      admin = create(:admin_user)
      expect(admin.api_token).to be_present
      expect(admin.api_token.length).to eq(64)
    end

    it "does not overwrite existing api_token" do
      existing_token = SecureRandom.hex(32)
      admin = create(:admin_user, api_token: existing_token)
      expect(admin.api_token).to eq(existing_token)
    end
  end

  describe "#regenerate_api_token!" do
    it "generates a new api_token" do
      admin = create(:admin_user)
      old_token = admin.api_token
      admin.regenerate_api_token!
      expect(admin.api_token).not_to eq(old_token)
      expect(admin.api_token.length).to eq(64)
    end
  end
end
