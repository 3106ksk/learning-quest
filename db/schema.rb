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

ActiveRecord::Schema[8.1].define(version: 2026_07_24_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "study_records", force: :cascade do |t|
    t.string "activity", limit: 100
    t.integer "actual_seconds"
    t.datetime "created_at", null: false
    t.datetime "current_pause_started_at"
    t.datetime "ended_at"
    t.datetime "expires_at", null: false
    t.integer "pause_count", default: 0, null: false
    t.integer "paused_seconds", default: 0, null: false
    t.integer "planned_minutes", null: false
    t.datetime "started_at", null: false
    t.string "status", default: "running", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_study_records_on_active_user_id", unique: true, where: "((status)::text = ANY ((ARRAY['running'::character varying, 'paused'::character varying, 'awaiting_extend_or_finish'::character varying, 'awaiting_evaluation'::character varying])::text[]))"
    t.index ["user_id"], name: "index_study_records_on_user_id"
    t.check_constraint "planned_minutes = ANY (ARRAY[5, 15, 25, 50])", name: "planned_minutes_allowed_values"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "name"
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "study_records", "users"
end
