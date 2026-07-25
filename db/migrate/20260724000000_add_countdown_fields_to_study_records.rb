class AddCountdownFieldsToStudyRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :study_records, :expires_at, :datetime, null: false
    add_column :study_records, :current_pause_started_at, :datetime
    add_column :study_records, :paused_seconds, :integer, default: 0, null: false
    add_column :study_records, :pause_count, :integer, default: 0, null: false
    add_column :study_records, :ended_at, :datetime
    add_column :study_records, :actual_seconds, :integer
  end
end
