require "rails_helper"

RSpec.describe "Thoughts", type: :request do
  describe "GET /" do
    it "displays the timeline" do
      thoughts = create_list(:thought, 3, :with_tags)
      get root_path

      expect(response).to have_http_status(:ok)
      thoughts.each do |thought|
        expect(response.body).to include(thought.content)
      end
    end

    it "shows thoughts in reverse chronological order" do
      old_thought = create(:thought, content: "Old thought", created_at: 1.day.ago)
      new_thought = create(:thought, content: "New thought", created_at: 1.hour.ago)

      get root_path

      expect(response.body.index(new_thought.content)).to be < response.body.index(old_thought.content)
    end

    it "filters by tag when tag param is present" do
      rails_thought = create(:thought, content: "Rails is great", tags: [ "rails" ])
      ruby_thought = create(:thought, content: "Ruby is awesome", tags: [ "ruby" ])

      get root_path, params: { tag: "rails" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(rails_thought.content)
      expect(response.body).not_to include(ruby_thought.content)
    end

    it "displays popular tags sidebar" do
      create(:thought, tags: [ "rails", "ruby" ])
      create(:thought, tags: [ "rails" ])

      get root_path

      expect(response.body).to include("#rails")
      expect(response.body).to include("#ruby")
    end

    it "searches thoughts by content" do
      matching = create(:thought, content: "Learning Ruby is fun")
      non_matching = create(:thought, content: "JavaScript rocks")

      get root_path, params: { q: "ruby" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(matching.content)
      expect(response.body).not_to include(non_matching.content)
    end
  end

  describe "GET /thoughts/:id" do
    let(:thought) { create(:thought, :with_tags) }

    it "displays the thought" do
      get thought_path(thought)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(thought.content)
    end

    it "increments the view count" do
      expect {
        get thought_path(thought)
      }.to change { thought.reload.view_count }.by(1)
    end

    it "displays tags as links" do
      get thought_path(thought)

      thought.tags.each do |tag|
        expect(response.body).to include("##{tag}")
      end
    end
  end
end
