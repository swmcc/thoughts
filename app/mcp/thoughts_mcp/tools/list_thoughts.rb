module ThoughtsMcp
  module Tools
    class ListThoughts < Base
      tool_name "list_thoughts"
      description "List recent top-level thoughts, newest first, optionally filtered by tag."
      input_schema(
        properties: {
          tag: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: MAX_LIMIT }
        }
      )
      annotations(read_only_hint: true)

      def self.call(tag: nil, limit: nil, server_context: nil)
        scope = Thought.top_level.recent.limit(limit_for(limit))
        scope = scope.with_tag(tag.downcase) if tag.present?
        ok(thoughts: scope.map { |t| serialize(t) })
      end
    end
  end
end
