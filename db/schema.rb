# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170810141511) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "document_type"
    t.binary   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "bookmarks", ["document_id"], name: "index_bookmarks_on_document_id"
  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "cas_users", force: :cascade do |t|
    t.string   "cas_directory_id"
    t.string   "name"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "admin",            default: false
  end

  add_index "cas_users", ["cas_directory_id"], name: "index_cas_users_on_cas_directory_id", unique: true

  create_table "download_urls", force: :cascade do |t|
    t.string   "token"
    t.string   "url"
    t.string   "title"
    t.text     "notes"
    t.string   "mime_type"
    t.string   "creator"
    t.boolean  "enabled"
    t.string   "request_ip"
    t.string   "request_user_agent"
    t.datetime "accessed_at"
    t.datetime "download_completed_at"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "expires_at"
  end

  add_index "download_urls", ["token"], name: "index_download_urls_on_token", unique: true

  create_table "searches", force: :cascade do |t|
    t.binary   "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

end
