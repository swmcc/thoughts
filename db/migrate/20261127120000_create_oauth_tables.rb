class CreateOauthTables < ActiveRecord::Migration[8.1]
  def change
    create_table :oauth_clients do |t|
      t.string :client_id, null: false
      t.string :client_secret_digest
      t.string :client_name, null: false
      t.string :redirect_uris, array: true, default: [], null: false
      t.timestamps
    end
    add_index :oauth_clients, :client_id, unique: true

    create_table :oauth_authorization_codes do |t|
      t.references :oauth_client, null: false, foreign_key: true
      t.references :admin_user, null: false, foreign_key: true
      t.string :code_digest, null: false
      t.string :redirect_uri, null: false
      t.string :code_challenge, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at
      t.timestamps
    end
    add_index :oauth_authorization_codes, :code_digest, unique: true

    create_table :oauth_access_tokens do |t|
      t.references :oauth_client, null: false, foreign_key: true
      t.references :admin_user, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.string :refresh_token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :refresh_expires_at, null: false
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :oauth_access_tokens, :token_digest, unique: true
    add_index :oauth_access_tokens, :refresh_token_digest, unique: true
  end
end
