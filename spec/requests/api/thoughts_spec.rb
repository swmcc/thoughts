require "rails_helper"

RSpec.describe "Api::Thoughts", type: :request do
  let(:admin) { create(:admin_user) }
  let(:auth_headers) { { "Authorization" => "Bearer #{admin.api_token}" } }

  describe "GET /api/thoughts" do
    context "without authentication (public)" do
      it "returns all thoughts" do
        thoughts = create_list(:thought, 3, :with_tags)
        get api_thoughts_path

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["thoughts"].length).to eq(3)
      end

      it "returns thoughts in reverse chronological order" do
        old_thought = create(:thought, created_at: 1.day.ago)
        new_thought = create(:thought, created_at: 1.hour.ago)

        get api_thoughts_path

        json = JSON.parse(response.body)
        expect(json["thoughts"].first["id"]).to eq(new_thought.id)
      end

      it "filters by tag" do
        rails_thought = create(:thought, content: "Rails thought", tags: [ "rails" ])
        create(:thought, content: "Ruby thought", tags: [ "ruby" ])

        get api_thoughts_path, params: { tag: "rails" }

        json = JSON.parse(response.body)
        expect(json["thoughts"].length).to eq(1)
        expect(json["thoughts"].first["id"]).to eq(rails_thought.id)
      end

      it "includes pagination metadata" do
        create_list(:thought, 25)
        get api_thoughts_path

        json = JSON.parse(response.body)
        expect(json["meta"]["total"]).to eq(25)
        expect(json["meta"]["page"]).to eq(1)
        expect(json["meta"]["per_page"]).to eq(20)
      end

      it "increments view count for each thought" do
        thought = create(:thought, view_count: 0)
        get api_thoughts_path

        expect(thought.reload.view_count).to eq(1)
      end

      it "returns proper JSON structure" do
        thought = create(:thought, :with_tags)
        get api_thoughts_path

        json = JSON.parse(response.body)
        thought_json = json["thoughts"].first

        expect(thought_json).to include(
          "id" => thought.id,
          "content" => thought.content,
          "tags" => thought.tags
        )
        expect(thought_json["created_at"]).to be_present
      end
    end

    context "with authentication" do
      it "does not increment view count" do
        thought = create(:thought, view_count: 0)
        get api_thoughts_path, headers: auth_headers

        expect(thought.reload.view_count).to eq(0)
      end
    end
  end

  describe "GET /api/thoughts/:id" do
    let(:thought) { create(:thought, :with_tags) }

    context "without authentication" do
      it "returns the thought" do
        get api_thought_path(thought)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["thought"]["id"]).to eq(thought.id)
        expect(json["thought"]["content"]).to eq(thought.content)
        expect(json["thought"]["tags"]).to eq(thought.tags)
      end

      it "increments view count" do
        expect {
          get api_thought_path(thought)
        }.to change { thought.reload.view_count }.by(1)
      end
    end

    context "with authentication" do
      it "does not increment view count" do
        expect {
          get api_thought_path(thought), headers: auth_headers
        }.not_to change { thought.reload.view_count }
      end
    end

    it "returns 404 for non-existent thought" do
      get api_thought_path(id: 99999)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/thoughts" do
    let(:valid_params) { { thought: { content: "A new thought!", tags: [ "test" ] } } }

    context "without authentication" do
      it "returns 401 unauthorized" do
        post api_thoughts_path, params: valid_params

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Invalid or missing API token")
      end
    end

    context "with authentication" do
      it "creates a new thought" do
        expect {
          post api_thoughts_path, params: valid_params, headers: auth_headers
        }.to change(Thought, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["thought"]["content"]).to eq("A new thought!")
        expect(json["thought"]["tags"]).to eq([ "test" ])
      end

      it "returns errors for invalid content" do
        post api_thoughts_path, params: { thought: { content: "" } }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]["content"]).to include("can't be blank")
      end

      it "returns errors for content too long" do
        post api_thoughts_path, params: { thought: { content: "A" * 141 } }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]["content"]).to include("is too long (maximum is 140 characters)")
      end
    end

    context "with invalid token" do
      it "returns 401 unauthorized" do
        post api_thoughts_path, params: valid_params, headers: { "Authorization" => "Bearer invalid" }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/thoughts/:id" do
    let(:thought) { create(:thought, content: "Original") }

    context "without authentication" do
      it "returns 401 unauthorized" do
        patch api_thought_path(thought), params: { thought: { content: "Updated" } }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with authentication" do
      it "updates the thought" do
        patch api_thought_path(thought), params: { thought: { content: "Updated", tags: [ "new" ] } }, headers: auth_headers

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["thought"]["content"]).to eq("Updated")
        expect(json["thought"]["tags"]).to eq([ "new" ])
      end

      it "returns errors for invalid updates" do
        patch api_thought_path(thought), params: { thought: { content: "" } }, headers: auth_headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(thought.reload.content).to eq("Original")
      end
    end
  end

  describe "DELETE /api/thoughts/:id" do
    let!(:thought) { create(:thought) }

    context "without authentication" do
      it "returns 401 unauthorized" do
        delete api_thought_path(thought)

        expect(response).to have_http_status(:unauthorized)
        expect(Thought.exists?(thought.id)).to be true
      end
    end

    context "with authentication" do
      it "deletes the thought" do
        expect {
          delete api_thought_path(thought), headers: auth_headers
        }.to change(Thought, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "GET /api/tags" do
    it "returns all unique tags" do
      create(:thought, tags: [ "rails", "ruby" ])
      create(:thought, tags: [ "rails", "elixir" ])

      get api_tags_path

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["tags"]).to contain_exactly("elixir", "rails", "ruby")
    end
  end
end
