module ThoughtsMcp
  module Tools
    class SearchThoughts < Base
      tool_name "search_thoughts"
      description "Search thoughts (including replies) whose content contains the query text."
      input_schema(
        properties: {
          query: { type: "string", minLength: 1 },
          limit: { type: "integer", minimum: 1, maximum: MAX_LIMIT }
        },
        required: [ "query" ]
      )
      annotations(read_only_hint: true)

      def self.call(query:, limit: nil, server_context: nil)
        escaped = ActiveRecord::Base.sanitize_sql_like(query)
        ok(thoughts: Thought.search(escaped).recent.limit(limit_for(limit)).map { |t| serialize(t) })
      end
    end
  end
end
