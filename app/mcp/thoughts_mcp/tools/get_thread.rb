module ThoughtsMcp
  module Tools
    class GetThread < Base
      tool_name "get_thread"
      description "Get the whole conversation a thought belongs to, from its root down through all replies."
      input_schema(properties: { id: { type: "string" } }, required: [ "id" ])
      annotations(read_only_hint: true)

      def self.call(id:, server_context: nil)
        thought = Thought.find_by(public_id: id)
        return error("No thought with id #{id}") if thought.nil?

        ok(thought: serialize(thought.thread_root, include_replies: true))
      end
    end
  end
end
