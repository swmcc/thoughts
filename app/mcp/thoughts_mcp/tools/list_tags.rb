module ThoughtsMcp
  module Tools
    class ListTags < Base
      tool_name "list_tags"
      description "List every tag in use, alphabetically."
      annotations(read_only_hint: true)

      def self.call(server_context: nil)
        ok(tags: Thought.pluck(:tags).flatten.uniq.compact.sort)
      end
    end
  end
end
