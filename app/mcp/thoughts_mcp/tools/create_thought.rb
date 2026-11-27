module ThoughtsMcp
  module Tools
    class CreateThought < Base
      tool_name "create_thought"
      description "Publish a new thought (max #{Thought::MAX_CONTENT_LENGTH} characters). It is marked as written by an agent."
      input_schema(
        properties: {
          content: { type: "string", maxLength: Thought::MAX_CONTENT_LENGTH },
          tags: { type: "array", items: { type: "string" } }
        },
        required: [ "content" ]
      )
      annotations(destructive_hint: false, open_world_hint: false)

      def self.call(content:, tags: [], server_context:)
        save_from_agent(Thought.new(content: content, tags: tags), server_context)
      end
    end
  end
end
