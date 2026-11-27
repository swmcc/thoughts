module ThoughtsMcp
  module Tools
    class ReplyToThought < Base
      tool_name "reply_to_thought"
      description "Reply to an existing thought by its id. The reply is marked as written by an agent."
      input_schema(
        properties: {
          parent_id: { type: "string" },
          content: { type: "string", maxLength: Thought::MAX_CONTENT_LENGTH },
          tags: { type: "array", items: { type: "string" } }
        },
        required: [ "parent_id", "content" ]
      )
      annotations(destructive_hint: false, open_world_hint: false)

      def self.call(parent_id:, content:, tags: [], server_context:)
        parent = Thought.find_by(public_id: parent_id)
        return error("No thought with id #{parent_id}") if parent.nil?

        save_from_agent(Thought.new(content: content, tags: tags, parent: parent), server_context)
      end
    end
  end
end
