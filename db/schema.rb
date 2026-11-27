# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_27_120100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_admin_users_on_api_token", unique: true
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "oauth_client_id", null: false
    t.bigint "admin_user_id", null: false
    t.string "token_digest", null: false
    t.string "refresh_token_digest", null: false
    t.datetime "expires_at", null: false
    t.datetime "refresh_expires_at", null: false
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_oauth_access_tokens_on_admin_user_id"
    t.index ["oauth_client_id"], name: "index_oauth_access_tokens_on_oauth_client_id"
    t.index ["refresh_token_digest"], name: "index_oauth_access_tokens_on_refresh_token_digest", unique: true
    t.index ["token_digest"], name: "index_oauth_access_tokens_on_token_digest", unique: true
  end

  create_table "oauth_authorization_codes", force: :cascade do |t|
    t.bigint "oauth_client_id", null: false
    t.bigint "admin_user_id", null: false
    t.string "code_digest", null: false
    t.string "redirect_uri", null: false
    t.string "code_challenge", null: false
    t.datetime "expires_at", null: false
    t.datetime "used_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_user_id"], name: "index_oauth_authorization_codes_on_admin_user_id"
    t.index ["code_digest"], name: "index_oauth_authorization_codes_on_code_digest", unique: true
    t.index ["oauth_client_id"], name: "index_oauth_authorization_codes_on_oauth_client_id"
  end

  create_table "oauth_clients", force: :cascade do |t|
    t.string "client_id", null: false
    t.string "client_secret_digest"
    t.string "client_name", null: false
    t.string "redirect_uris", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_oauth_clients_on_client_id", unique: true
  end

  create_table "thoughts", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.string "link_description"
    t.string "link_image"
    t.jsonb "link_previews", default: []
    t.string "link_title"
    t.string "link_url"
    t.bigint "parent_id"
    t.string "public_id", null: false
    t.string "source", default: "web", null: false
    t.string "tags", default: [], array: true
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0
    t.string "agent_client"
    t.index ["created_at"], name: "index_thoughts_on_created_at"
    t.index ["parent_id"], name: "index_thoughts_on_parent_id"
    t.index ["public_id"], name: "index_thoughts_on_public_id", unique: true
    t.index ["tags"], name: "index_thoughts_on_tags", using: :gin
  end

  add_foreign_key "oauth_access_tokens", "admin_users"
  add_foreign_key "oauth_access_tokens", "oauth_clients"
  add_foreign_key "oauth_authorization_codes", "admin_users"
  add_foreign_key "oauth_authorization_codes", "oauth_clients"
  add_foreign_key "thoughts", "thoughts", column: "parent_id"
end
