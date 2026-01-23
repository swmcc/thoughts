class CreateThoughts < ActiveRecord::Migration[8.1]
  def change
    create_table :thoughts do |t|
      t.text :content, null: false
      t.string :tags, array: true, default: []
      t.integer :view_count, default: 0

      t.timestamps
    end

    add_index :thoughts, :tags, using: "gin"
    add_index :thoughts, :created_at
  end
end
