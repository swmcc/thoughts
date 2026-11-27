module ThoughtsMcp
  module Tools
    class Base < MCP::Tool
      MAX_LIMIT = 50

      class << self
        private

        def ok(payload)
          MCP::Tool::Response.new([ { type: "text", text: JSON.pretty_generate(payload) } ])
        end

        def error(message)
          MCP::Tool::Response.new([ { type: "text", text: message } ], error: true)
        end

        def limit_for(limit)
          (limit || 10).to_i.clamp(1, MAX_LIMIT)
        end

        def save_from_agent(thought, server_context)
          token = server_context[:access_token]
          thought.source = "agent"
          thought.agent_client = token.client.client_name

          if thought.save
            ok(thought: serialize(thought))
          else
            error("Could not save thought: #{thought.errors.full_messages.to_sentence}")
          end
        end

        def serialize(thought, include_replies: false)
          json = {
            id: thought.public_id,
            content: thought.content,
            tags: thought.tags,
            source: thought.source,
            parent_id: thought.parent&.public_id,
            created_at: thought.created_at.iso8601
          }
          json[:replies] = thought.replies.map { |r| serialize(r, include_replies: true) } if include_replies
          json
        end
      end
    end
  end
end
