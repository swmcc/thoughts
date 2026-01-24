class AddPublicIdToThoughts < ActiveRecord::Migration[8.1]
  def up
    add_column :thoughts, :public_id, :string
    add_index :thoughts, :public_id, unique: true

    # Backfill existing records
    Thought.reset_column_information
    Thought.where(public_id: nil).find_each do |thought|
      thought.update_column(:public_id, SecureRandom.alphanumeric(12))
    end

    change_column_null :thoughts, :public_id, false
  end

  def down
    remove_column :thoughts, :public_id
  end
end
