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

ActiveRecord::Schema[7.1].define(version: 2025_07_01_163954) do
  create_schema "auth"
  create_schema "extensions"
  create_schema "graphql"
  create_schema "graphql_public"
  create_schema "pgbouncer"
  create_schema "pgsodium"
  create_schema "pgsodium_masks"
  create_schema "realtime"
  create_schema "storage"
  create_schema "vault"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_graphql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "pgjwt"
  enable_extension "pgsodium"
  enable_extension "plpgsql"
  enable_extension "supabase_vault"
  enable_extension "uuid-ossp"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "animals", force: :cascade do |t|
    t.string "name"
    t.string "age"
    t.string "description"
    t.string "photo"
    t.string "sex"
    t.string "species"
    t.string "shelter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "races_label"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.bigint "user_id", null: false
    t.datetime "start_time", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reason"
    t.bigint "pet_id", null: false
    t.string "comment"
    t.index ["pet_id"], name: "index_appointments_on_pet_id"
    t.index ["professional_id"], name: "index_appointments_on_professional_id"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "closing_hours", force: :cascade do |t|
    t.bigint "professional_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "whole_day", default: false
    t.index ["professional_id"], name: "index_closing_hours_on_professional_id"
  end

  create_table "content_blocks", force: :cascade do |t|
    t.integer "position", null: false
    t.text "body", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image"
    t.index ["post_id"], name: "index_content_blocks_on_post_id"
  end

  create_table "national_days_offs", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "opening_hours", force: :cascade do |t|
    t.integer "day_of_week"
    t.time "open_time_morning"
    t.time "close_time_morning"
    t.boolean "closed"
    t.bigint "professional_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "open_time_afternoon"
    t.time "close_time_afternoon"
    t.index ["professional_id"], name: "index_opening_hours_on_professional_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "state"
    t.string "checkout_session_id"
    t.bigint "user_id", null: false
    t.bigint "pricing_id", null: false
    t.integer "amount_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "pro_signup_token"
    t.integer "pro_accounts_created"
    t.index ["pricing_id"], name: "index_orders_on_pricing_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "pet_alerts", force: :cascade do |t|
    t.bigint "user_id"
    t.string "title"
    t.string "description"
    t.string "location"
    t.datetime "date"
    t.string "contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "status"
    t.string "photo_url"
    t.float "latitude"
    t.float "longitude"
    t.index ["user_id"], name: "index_pet_alerts_on_user_id"
  end

  create_table "pets", force: :cascade do |t|
    t.string "name"
    t.string "age"
    t.string "description"
    t.string "photo"
    t.string "sex"
    t.string "species"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "races"
    t.date "birthday"
    t.string "identification"
    t.string "spayed_neutered"
    t.string "medical_background"
    t.string "photo_url"
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.string "meta_title", null: false
    t.string "meta_description", null: false
    t.text "intro", null: false
    t.text "conclusion", null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cover_image"
    t.string "meta_keywords", default: [], array: true
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end

  create_table "pricings", force: :cascade do |t|
    t.string "specialty"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents", default: 0, null: false
    t.string "title"
    t.string "description"
    t.integer "capacity"
    t.string "stripe_price_id"
    t.string "description_details", default: [], array: true
  end

  create_table "professionals", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "phone"
    t.string "email"
    t.string "specialty"
    t.string "description"
    t.integer "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.float "latitude"
    t.float "longitude"
    t.integer "capacity"
    t.integer "interval"
    t.jsonb "photos_url", default: []
    t.boolean "homeVisit"
    t.boolean "acceptUrgentVisit"
    t.index ["user_id"], name: "index_professionals_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.string "content"
    t.integer "rating"
    t.bigint "professional_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["professional_id"], name: "index_reviews_on_professional_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "uuid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vaccinations", force: :cascade do |t|
    t.string "name"
    t.date "administration_date"
    t.date "next_booster_date"
    t.string "vet_name"
    t.integer "vet_phone"
    t.bigint "pet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_vaccinations_on_pet_id"
  end

  create_table "weight_histories", force: :cascade do |t|
    t.float "weight"
    t.date "date"
    t.bigint "pet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id"], name: "index_weight_histories_on_pet_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "appointments", "pets"
  add_foreign_key "appointments", "professionals"
  add_foreign_key "appointments", "users"
  add_foreign_key "closing_hours", "professionals"
  add_foreign_key "content_blocks", "posts", name: "content_blocks_post_id_fkey", on_update: :cascade, on_delete: :cascade
  add_foreign_key "opening_hours", "professionals"
  add_foreign_key "orders", "pricings"
  add_foreign_key "orders", "users"
  add_foreign_key "pet_alerts", "users"
  add_foreign_key "pets", "users"
  add_foreign_key "professionals", "users"
  add_foreign_key "reviews", "professionals"
  add_foreign_key "reviews", "users"
  add_foreign_key "vaccinations", "pets"
  add_foreign_key "weight_histories", "pets"
end
