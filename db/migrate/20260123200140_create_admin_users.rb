class CreateAdminUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :api_token

      t.timestamps
    end
    add_index :admin_users, :email, unique: true
    add_index :admin_users, :api_token, unique: true
  end
end
