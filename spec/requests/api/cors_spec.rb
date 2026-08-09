require "rails_helper"

RSpec.describe "API CORS", type: :request do
  describe "GET /api/thoughts" do
    it "allows cross-origin reads from swm.cc" do
      get "/api/thoughts", headers: { "Origin" => "https://swm.cc" }

      expect(response).to have_http_status(:ok)
      expect(response.headers["Access-Control-Allow-Origin"]).to eq("https://swm.cc")
    end

    it "does not allow other origins" do
      get "/api/thoughts", headers: { "Origin" => "https://example.com" }

      expect(response).to have_http_status(:ok)
      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end

    it "answers preflight requests for swm.cc" do
      options "/api/thoughts", headers: {
        "Origin" => "https://swm.cc",
        "Access-Control-Request-Method" => "GET"
      }

      expect(response.headers["Access-Control-Allow-Origin"]).to eq("https://swm.cc")
      expect(response.headers["Access-Control-Allow-Methods"]).to include("GET")
    end
  end

  describe "non-API routes" do
    it "does not expose CORS headers" do
      get "/", headers: { "Origin" => "https://swm.cc" }

      expect(response.headers["Access-Control-Allow-Origin"]).to be_nil
    end
  end
end
