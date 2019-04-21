# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_04_17_134536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.bigint "feed_id", null: false
    t.string "title", null: false
    t.string "link", null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id"], name: "index_articles_on_feed_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url", null: false
    t.string "title", null: false
    t.string "content_type", null: false
    t.string "etag"
    t.text "rss_content"
    t.datetime "reloaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "packs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "token", null: false
    t.text "rss_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_packs_on_token", unique: true
    t.index ["user_id"], name: "index_packs_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "pack_id"
    t.bigint "feed_id"
    t.datetime "read_timestamp"
    t.text "message"
    t.datetime "messaged_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feed_id"], name: "index_subscriptions_on_feed_id"
    t.index ["pack_id"], name: "index_subscriptions_on_pack_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "articles", "feeds"
  add_foreign_key "packs", "users"
  add_foreign_key "subscriptions", "feeds"
  add_foreign_key "subscriptions", "packs"
end
