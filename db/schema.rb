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

ActiveRecord::Schema[8.1].define(version: 2026_09_05_001855) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "challenge_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "label", null: false
    t.integer "point", null: false
    t.integer "position", null: false
    t.string "result_code", null: false
    t.datetime "updated_at", null: false
    t.index ["result_code"], name: "index_challenge_options_on_result_code", unique: true
    t.check_constraint "point >= 1 AND point <= 3", name: "challenge_options_point_range"
  end

  create_table "evaluations", force: :cascade do |t|
    t.bigint "challenge_option_id", null: false
    t.integer "challenge_point", null: false
    t.datetime "created_at", null: false
    t.bigint "focus_option_id", null: false
    t.integer "focus_point", null: false
    t.bigint "study_record_id", null: false
    t.datetime "updated_at", null: false
    t.index ["challenge_option_id"], name: "index_evaluations_on_challenge_option_id"
    t.index ["focus_option_id"], name: "index_evaluations_on_focus_option_id"
    t.index ["study_record_id"], name: "index_evaluations_on_study_record_id", unique: true
    t.check_constraint "challenge_point >= 1 AND challenge_point <= 3", name: "evaluations_challenge_point_range"
    t.check_constraint "focus_point >= 1 AND focus_point <= 3", name: "evaluations_focus_point_range"
  end

  create_table "focus_options", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "label", null: false
    t.integer "point", null: false
    t.integer "position", null: false
    t.string "result_code", null: false
    t.datetime "updated_at", null: false
    t.index ["result_code"], name: "index_focus_options_on_result_code", unique: true
    t.check_constraint "point >= 1 AND point <= 3", name: "focus_options_point_range"
  end

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
    t.string "rank"
    t.datetime "started_at", null: false
    t.string "status", default: "running", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_study_records_on_active_user_id", unique: true, where: "((status)::text = ANY ((ARRAY['running'::character varying, 'paused'::character varying, 'awaiting_evaluation'::character varying])::text[]))"
    t.index ["user_id"], name: "index_study_records_on_user_id"
    t.check_constraint "planned_minutes = ANY (ARRAY[5, 15, 25, 50])", name: "planned_minutes_allowed_values"
    t.check_constraint "rank::text = ANY (ARRAY['a'::character varying, 'b'::character varying, 'c'::character varying]::text[])", name: "study_records_rank_allowed_values"
    t.check_constraint "status::text <> 'evaluated'::text OR rank IS NOT NULL", name: "study_records_rank_required_when_evaluated"
  end

  create_table "users", force: :cascade do |t|
    t.string "account_name"
    t.datetime "created_at", null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["account_name"], name: "index_users_on_account_name", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "evaluations", "challenge_options"
  add_foreign_key "evaluations", "focus_options"
  add_foreign_key "evaluations", "study_records"
  add_foreign_key "sessions", "users"
  add_foreign_key "study_records", "users"
end
