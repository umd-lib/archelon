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

ActiveRecord::Schema.define(version: 2021_10_29_134635) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type"
    t.string "document_id"
    t.string "document_type"
    t.binary "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_bookmarks_on_document_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "cas_users", force: :cascade do |t|
    t.string "cas_directory_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_type"
    t.index ["cas_directory_id"], name: "index_cas_users_on_cas_directory_id", unique: true
  end

  create_table "cas_users_groups", id: false, force: :cascade do |t|
    t.integer "cas_user_id"
    t.integer "group_id"
    t.index ["cas_user_id"], name: "index_cas_users_groups_on_cas_user_id"
    t.index ["group_id"], name: "index_cas_users_groups_on_group_id"
  end

  create_table "datatypes", force: :cascade do |t|
    t.string "identifier"
    t.integer "vocabulary_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vocabulary_id"], name: "index_datatypes_on_vocabulary_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "download_urls", force: :cascade do |t|
    t.string "token"
    t.string "url"
    t.string "title"
    t.text "notes"
    t.string "mime_type"
    t.string "creator"
    t.boolean "enabled"
    t.string "request_ip"
    t.string "request_user_agent"
    t.datetime "accessed_at"
    t.datetime "download_completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.index ["token"], name: "index_download_urls_on_token", unique: true
  end

  create_table "export_job_requests", force: :cascade do |t|
    t.integer "export_job_id"
    t.boolean "validate_only"
    t.boolean "resume"
    t.string "job_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["export_job_id"], name: "index_export_job_requests_on_export_job_id"
  end

  create_table "export_jobs", force: :cascade do |t|
    t.string "format"
    t.integer "cas_user_id"
    t.datetime "timestamp"
    t.string "name"
    t.integer "item_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "progress"
    t.boolean "export_binaries"
    t.integer "binaries_size"
    t.integer "binaries_count"
    t.string "mime_types"
    t.integer "state"
    t.string "uris"
    t.index ["cas_user_id"], name: "index_export_jobs_on_cas_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "import_job_requests", force: :cascade do |t|
    t.integer "import_job_id"
    t.boolean "validate_only"
    t.boolean "resume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "job_id"
    t.index ["import_job_id"], name: "index_import_job_requests_on_import_job_id"
  end

  create_table "import_jobs", force: :cascade do |t|
    t.integer "cas_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "timestamp"
    t.string "name"
    t.integer "progress"
    t.string "model"
    t.string "access"
    t.string "collection"
    t.string "binaries_location"
    t.integer "binaries_count"
    t.integer "item_count"
    t.integer "state"
    t.index ["cas_user_id"], name: "index_import_jobs_on_cas_user_id"
  end

  create_table "individuals", force: :cascade do |t|
    t.string "identifier"
    t.string "label"
    t.string "same_as"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vocabulary_id"
    t.index ["vocabulary_id"], name: "index_individuals_on_vocabulary_id"
  end

  create_table "public_keys", force: :cascade do |t|
    t.string "key"
    t.integer "cas_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cas_user_id"], name: "index_public_keys_on_cas_user_id"
  end

  create_table "searches", force: :cascade do |t|
    t.binary "query_params"
    t.integer "user_id"
    t.string "user_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_searches_on_user_id"
  end

  create_table "types", force: :cascade do |t|
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "vocabulary_id"
    t.index ["vocabulary_id"], name: "index_types_on_vocabulary_id"
  end

  create_table "vocabularies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "identifier"
    t.string "description"
  end

end
