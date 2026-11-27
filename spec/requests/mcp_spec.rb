require "rails_helper"

RSpec.describe "MCP endpoint", type: :request do
  let(:client) { register_client(name: "Claude Code") }
  let(:token) { issue_access_token(client: client) }
  let(:headers) { { "Authorization" => "Bearer #{token}", "Content-Type" => "application/json", "Accept" => "application/json, text/event-stream" } }

  def rpc(method, params = {}, id: 1)
    post "/mcp", params: { jsonrpc: "2.0", id: id, method: method, params: params }.to_json, headers: headers
    JSON.parse(response.body)
  end

  def call_tool(name, arguments = {})
    result = rpc("tools/call", { name: name, arguments: arguments })["result"]
    [ result, result["isError"] ? result["content"].first["text"] : JSON.parse(result["content"].first["text"]) ]
  end

  describe "authentication" do
    it "challenges requests without a token with resource metadata" do
      post "/mcp", params: {}.to_json, headers: { "Content-Type" => "application/json" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["WWW-Authenticate"])
        .to eq(%(Bearer resource_metadata="http://www.example.com/.well-known/oauth-protected-resource"))
    end

    it "rejects expired tokens" do
      token
      travel 61.minutes do
        post "/mcp", params: {}.to_json, headers: headers
        expect(response).to have_http_status(:unauthorized)
      end
    end

    it "rejects GET with 405" do
      get "/mcp", headers: headers
      expect(response).to have_http_status(:method_not_allowed)
    end
  end

  it "initializes" do
    body = rpc("initialize", { protocolVersion: "2025-06-18", capabilities: {}, clientInfo: { name: "test", version: "1" } })
    expect(body.dig("result", "serverInfo", "name")).to eq("thoughts")
  end

  it "accepts notifications with 202" do
    post "/mcp", params: { jsonrpc: "2.0", method: "notifications/initialized" }.to_json, headers: headers
    expect(response).to have_http_status(:accepted)
  end

  it "lists the tools, with no edit or delete" do
    names = rpc("tools/list").dig("result", "tools").map { |t| t["name"] }
    expect(names).to contain_exactly("create_thought", "reply_to_thought", "list_thoughts",
                                     "search_thoughts", "get_thread", "list_tags")
  end

  describe "create_thought" do
    it "creates a thought marked as written by the agent" do
      _, payload = call_tool("create_thought", content: "Hello from an agent", tags: [ "AI" ])

      thought = Thought.find_by!(public_id: payload.dig("thought", "id"))
      expect(thought).to have_attributes(source: "agent", agent_client: "Claude Code", tags: [ "ai" ])
      expect(thought.source_label).to eq("Written by an agent (Claude Code)")
    end

    it "returns a tool error for content that is too long" do
      result, = call_tool("create_thought", content: "a" * 141)
      expect(result["isError"]).to be(true)
      expect(Thought.count).to eq(0)
    end
  end

  describe "reply_to_thought" do
    it "replies to a thought" do
      parent = create(:thought)
      _, payload = call_tool("reply_to_thought", parent_id: parent.public_id, content: "Agreed")

      expect(parent.replies.sole).to have_attributes(content: "Agreed", source: "agent")
      expect(payload.dig("thought", "parent_id")).to eq(parent.public_id)
    end

    it "errors for an unknown parent" do
      result, text = call_tool("reply_to_thought", parent_id: "nope", content: "Hi")
      expect(result["isError"]).to be(true)
      expect(text).to include("No thought with id nope")
    end
  end

  describe "read tools" do
    let!(:rails_thought) { create(:thought, content: "Rails is 100% fun", tags: [ "rails" ]) }
    let!(:ruby_thought) { create(:thought, content: "Ruby rocks", tags: [ "ruby" ]) }

    it "lists thoughts filtered by tag" do
      _, payload = call_tool("list_thoughts", tag: "rails")
      expect(payload["thoughts"].map { |t| t["id"] }).to eq([ rails_thought.public_id ])
    end

    it "searches, treating % literally" do
      _, payload = call_tool("search_thoughts", query: "100%")
      expect(payload["thoughts"].map { |t| t["id"] }).to eq([ rails_thought.public_id ])

      _, payload = call_tool("search_thoughts", query: "%")
      expect(payload["thoughts"].map { |t| t["id"] }).to eq([ rails_thought.public_id ])
    end

    it "gets a thread from any reply" do
      reply = create(:thought, parent: rails_thought, content: "Reply")
      _, payload = call_tool("get_thread", id: reply.public_id)

      expect(payload.dig("thought", "id")).to eq(rails_thought.public_id)
      expect(payload.dig("thought", "replies", 0, "id")).to eq(reply.public_id)
    end

    it "lists tags" do
      _, payload = call_tool("list_tags")
      expect(payload["tags"]).to eq(%w[rails ruby])
    end
  end
end
