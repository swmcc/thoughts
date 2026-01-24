require "rails_helper"

RSpec.describe "Admin::Sessions", type: :request do
  let(:admin) { create(:admin_user, email: "admin@example.com", password: "password123", password_confirmation: "password123") }

  describe "GET /admin/session/new" do
    it "renders the login form" do
      get new_admin_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Sign in")
    end

    it "redirects to admin root if already logged in" do
      post admin_session_path, params: { email: admin.email, password: "password123" }
      get new_admin_session_path
      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "POST /admin/session" do
    context "with valid credentials" do
      it "logs in and redirects to admin root" do
        post admin_session_path, params: { email: admin.email, password: "password123" }
        expect(response).to redirect_to(admin_root_path)
        follow_redirect!
        expect(response.body).to include("Welcome back!")
      end
    end

    context "with invalid credentials" do
      it "shows error and re-renders login form" do
        post admin_session_path, params: { email: admin.email, password: "wrong" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end

      it "fails with non-existent email" do
        post admin_session_path, params: { email: "noone@example.com", password: "password123" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid email or password")
      end
    end
  end

  describe "DELETE /admin/session" do
    it "logs out and redirects to login" do
      post admin_session_path, params: { email: admin.email, password: "password123" }
      delete admin_session_path
      expect(response).to redirect_to(new_admin_session_path)
      follow_redirect!
      expect(response.body).to include("You have been logged out")
    end
  end

  describe "POST /admin/regenerate_token" do
    it "regenerates the API token" do
      post admin_session_path, params: { email: admin.email, password: "password123" }
      old_token = admin.api_token

      post admin_regenerate_token_path
      expect(response).to redirect_to(admin_root_path)
      expect(admin.reload.api_token).not_to eq(old_token)
    end
  end
end
