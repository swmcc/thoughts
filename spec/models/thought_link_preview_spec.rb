require "rails_helper"

RSpec.describe Thought, "#link previews" do
  def og_double(title:, image_url:)
    image = image_url && double("og image", url: image_url)
    og = double("og", title: title, description: "A description", image: image)
    double("OpenGraphReader result", og: og)
  end

  def stub_head_response(success:, content_type: "image/png")
    response = success ? Net::HTTPSuccess.new("1.1", "200", "OK") : Net::HTTPNotFound.new("1.1", "404", "Not Found")
    allow(response).to receive(:[]).with("content-type").and_return(content_type)
    allow(response).to receive(:[]).with("location").and_return(nil)
    allow(Net::HTTP).to receive(:start).and_return(response)
    response
  end

  describe "og:image validation" do
    it "stores the image when it serves an image content type" do
      stub_head_response(success: true)
      allow(OpenGraphReader).to receive(:fetch)
        .and_return(og_double(title: "A page", image_url: "https://example.com/og.png"))

      thought = create(:thought, content: "look at https://example.com/page")

      expect(thought.link_previews.first["image"]).to eq("https://example.com/og.png")
    end

    it "drops the image but keeps the preview when the og:image 404s" do
      stub_head_response(success: false, content_type: "text/html")
      allow(OpenGraphReader).to receive(:fetch)
        .and_return(og_double(title: "A page", image_url: "https://example.com/dead.png"))

      thought = create(:thought, content: "look at https://example.com/page")

      expect(thought.link_previews.first["title"]).to eq("A page")
      expect(thought.link_previews.first["image"]).to be_nil
    end

    it "drops the image when the URL serves a non-image content type" do
      stub_head_response(success: true, content_type: "text/html; charset=utf-8")
      allow(OpenGraphReader).to receive(:fetch)
        .and_return(og_double(title: "A page", image_url: "https://example.com/error-page"))

      thought = create(:thought, content: "look at https://example.com/page")

      expect(thought.link_previews.first["image"]).to be_nil
    end

    it "stores no preview when there is no title and the image is dead" do
      stub_head_response(success: false, content_type: "text/html")
      allow(OpenGraphReader).to receive(:fetch)
        .and_return(og_double(title: nil, image_url: "https://example.com/dead.png"))

      thought = create(:thought, content: "look at https://example.com/page")

      expect(thought.link_previews).to be_empty
    end

    it "treats a network error while validating as a dead image" do
      allow(Net::HTTP).to receive(:start).and_raise(Errno::ECONNREFUSED)
      allow(OpenGraphReader).to receive(:fetch)
        .and_return(og_double(title: "A page", image_url: "https://example.com/og.png"))

      thought = create(:thought, content: "look at https://example.com/page")

      expect(thought.link_previews.first["image"]).to be_nil
      expect(thought.link_previews.first["title"]).to eq("A page")
    end
  end
end
