class AddAgentClientToThoughts < ActiveRecord::Migration[8.1]
  def change
    add_column :thoughts, :agent_client, :string
  end
end
