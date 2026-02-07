require "rails_helper"

RSpec.describe "Admin::Thoughts", type: :request do
  let(:admin) { create(:admin_user) }

  before do
    post admin_session_path, params: { email: admin.email, password: "password123" }
  end

  describe "GET /admin/thoughts" do
    it "displays all thoughts" do
      thoughts = create_list(:thought, 3)
      get admin_thoughts_path

      expect(response).to have_http_status(:ok)
      thoughts.each do |thought|
        expect(response.body).to include(thought.content)
      end
    end

    it "redirects to login when not authenticated" do
      delete admin_session_path
      get admin_thoughts_path
      expect(response).to redirect_to(new_admin_session_path)
    end
  end

  describe "GET /admin/thoughts/:id" do
    let(:thought) { create(:thought, :with_tags) }

    it "displays the thought details" do
      get admin_thought_path(thought)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(thought.content)
    end
  end

  describe "GET /admin/thoughts/new" do
    it "displays the new thought form" do
      get new_admin_thought_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("New Thought")
    end
  end

  describe "POST /admin/thoughts" do
    context "with valid params" do
      it "creates a new thought" do
        expect {
          post admin_thoughts_path, params: { thought: { content: "A new thought", tags: [ "test" ] } }
        }.to change(Thought, :count).by(1)

        expect(response).to redirect_to(admin_thoughts_path)
      end
    end

    context "with invalid params" do
      it "does not create a thought and re-renders form" do
        expect {
          post admin_thoughts_path, params: { thought: { content: "" } }
        }.not_to change(Thought, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it "shows error for content too long" do
        expect {
          post admin_thoughts_path, params: { thought: { content: "A" * 141 } }
        }.not_to change(Thought, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(response.body).to include("maximum is 140 characters")
      end
    end
  end

  describe "GET /admin/thoughts/:id/edit" do
    let(:thought) { create(:thought) }

    it "displays the edit form" do
      get edit_admin_thought_path(thought)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Edit Thought")
      expect(response.body).to include(thought.content)
    end
  end

  describe "PATCH /admin/thoughts/:id" do
    let(:thought) { create(:thought, content: "Original content") }

    context "with valid params" do
      it "updates the thought" do
        patch admin_thought_path(thought), params: { thought: { content: "Updated content" } }

        expect(response).to redirect_to(admin_thoughts_path)
        expect(thought.reload.content).to eq("Updated content")
      end
    end

    context "with invalid params" do
      it "does not update and re-renders form" do
        patch admin_thought_path(thought), params: { thought: { content: "" } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(thought.reload.content).to eq("Original content")
      end
    end
  end

  describe "DELETE /admin/thoughts/:id" do
    let!(:thought) { create(:thought) }

    it "deletes the thought" do
      expect {
        delete admin_thought_path(thought)
      }.to change(Thought, :count).by(-1)

      expect(response).to redirect_to(admin_thoughts_path)
    end
  end
end
