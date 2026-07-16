  class CreateStudyRecords < ActiveRecord::Migration[8.1]
    def change
      create_table :study_records do |t|
        t.references :user, null: false, foreign_key: true
        t.integer :planned_minutes, null: false
        t.string :activity, limit: 100
        t.string :status, null: false, default: "running"

        t.check_constraint "planned_minutes IN (5, 15, 25, 50)", name: "planned_minutes_allowed_values"

        t.timestamps
      end
  
      add_index :study_records, :user_id,
                unique: true,
                where: "status IN ('running', 'paused', 'awaiting_extend_or_finish', 'awaiting_evaluation')",
                name: "index_study_records_on_active_user_id"
    end
  end
