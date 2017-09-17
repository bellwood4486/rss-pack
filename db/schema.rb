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

ActiveRecord::Schema.define(version: 20170917142516) do

  create_table "blogs", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.integer "pack_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pack_id"], name: "index_blogs_on_pack_id"
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "url"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "content"
    t.datetime "refreshed_at"
    t.string "etag"
    t.string "content_type"
    t.integer "user_id"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "packs", force: :cascade do |t|
    t.string "rss_token"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "rss_content"
    t.datetime "rss_refreshed_at"
    t.string "name"
    t.index ["user_id"], name: "index_packs_on_user_id"
  end

  create_table "packs_and_feeds", id: false, force: :cascade do |t|
    t.integer "pack_id"
    t.integer "feed_id"
    t.index ["feed_id"], name: "index_packs_and_feeds_on_feed_id"
    t.index ["pack_id"], name: "index_packs_and_feeds_on_pack_id"
  end

  create_table "rss_feeds", force: :cascade do |t|
    t.string "url"
    t.text "content"
    t.datetime "refreshed_at"
    t.string "etag"
    t.integer "blog_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "content_type"
    t.string "title"
    t.index ["blog_id"], name: "index_rss_feeds_on_blog_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
  end

end
