class AddSourceToThoughts < ActiveRecord::Migration[8.1]
  def change
    add_column :thoughts, :source, :string, default: "web", null: false
  end
end
