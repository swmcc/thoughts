class AddParentToThoughts < ActiveRecord::Migration[8.1]
  def change
    add_reference :thoughts, :parent, null: true, index: true, foreign_key: { to_table: :thoughts }
  end
end
