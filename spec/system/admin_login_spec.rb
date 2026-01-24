require "rails_helper"

RSpec.describe "Admin Login", type: :system do
  let!(:admin) { create(:admin_user, email: "admin@example.com", password: "password123", password_confirmation: "password123") }

  it "allows admin to log in with valid credentials" do
    visit admin_root_path

    expect(page).to have_current_path(new_admin_session_path)
    expect(page).to have_content("Sign in")

    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    expect(page).to have_current_path(admin_root_path)
    expect(page).to have_content("Welcome back!")
    expect(page).to have_content(admin.email)
  end

  it "shows error with invalid credentials" do
    visit new_admin_session_path

    fill_in "Email", with: admin.email
    fill_in "Password", with: "wrongpassword"
    click_button "Sign in"

    expect(page).to have_content("Invalid email or password")
    expect(page).to have_field("Email")
  end

  it "allows admin to log out" do
    visit new_admin_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Sign in"

    expect(page).to have_current_path(admin_root_path)

    click_button "Logout"

    expect(page).to have_content("You have been logged out")
    expect(page).to have_current_path(new_admin_session_path)
  end
end
