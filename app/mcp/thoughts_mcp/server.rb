module ThoughtsMcp
  # Builds a fresh MCP server per request, scoped to the OAuth access token
  # that authenticated it. Anything written through it is sourced "agent".
  module Server
    TOOLS = [
      Tools::CreateThought,
      Tools::ReplyToThought,
      Tools::ListThoughts,
      Tools::SearchThoughts,
      Tools::GetThread,
      Tools::ListTags
    ].freeze

    INSTRUCTIONS = <<~TEXT.freeze
      Thoughts is a personal microblog. Posts are at most #{Thought::MAX_CONTENT_LENGTH} characters.
      Only create or reply when the user asks you to post; show them the exact text first if they haven't given it verbatim.
    TEXT

    def self.build(access_token:)
      MCP::Server.new(
        name: "thoughts",
        title: "Thoughts",
        version: "1.0.0",
        instructions: INSTRUCTIONS,
        tools: TOOLS,
        server_context: { access_token: access_token }
      )
    end
  end
end
