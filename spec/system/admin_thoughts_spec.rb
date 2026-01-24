require "rails_helper"

RSpec.describe "Admin Thoughts Management", type: :system do
  let!(:admin) { create(:admin_user, email: "admin@example.com", password: "password123", password_confirmation: "password123") }

  before do
    visit new_admin_session_path
    fill_in "Email", with: admin.email
    fill_in "Password", with: "password123"
    click_button "Sign in"
  end

  describe "viewing thoughts" do
    it "displays all thoughts on the index page" do
      thought = create(:thought, content: "Test thought content", tags: [ "test" ])

      visit admin_thoughts_path

      expect(page).to have_content("Test thought content")
      expect(page).to have_content("test")
    end
  end

  describe "creating a thought" do
    it "creates a new thought with content" do
      visit admin_thoughts_path
      click_link "New Thought"

      fill_in "Content", with: "A brand new thought!"
      click_button "Create Thought"

      expect(page).to have_content("Thought was successfully created")
      expect(page).to have_content("A brand new thought!")
    end

    it "shows validation errors for invalid content" do
      visit new_admin_thought_path

      fill_in "Content", with: ""
      click_button "Create Thought"

      expect(page).to have_content("can't be blank")
    end
  end

  describe "editing a thought" do
    let!(:thought) { create(:thought, content: "Original content") }

    it "updates the thought content" do
      visit admin_thoughts_path
      click_link "Edit"

      fill_in "Content", with: "Updated content"
      click_button "Update Thought"

      expect(page).to have_content("Thought was successfully updated")
      expect(page).to have_content("Updated content")
    end
  end

  describe "deleting a thought" do
    let!(:thought) { create(:thought, content: "To be deleted") }

    it "removes the thought" do
      visit admin_thoughts_path

      expect(page).to have_content("To be deleted")

      accept_confirm do
        click_button "Delete"
      end

      expect(page).to have_content("Thought was successfully deleted")
      expect(page).not_to have_content("To be deleted")
    end
  end

  describe "API token management" do
    it "displays the API token" do
      visit admin_thoughts_path

      expect(page).to have_content("API Token")
      expect(page).to have_content(admin.api_token)
    end

    it "allows regenerating the API token" do
      old_token = admin.api_token
      visit admin_thoughts_path

      accept_confirm do
        click_button "Regenerate"
      end

      expect(page).to have_content("API token regenerated successfully")
      expect(admin.reload.api_token).not_to eq(old_token)
    end
  end
end
