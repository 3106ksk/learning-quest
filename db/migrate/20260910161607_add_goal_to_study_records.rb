class AddGoalToStudyRecords < ActiveRecord::Migration[8.1]
  def change
    add_reference :study_records, :goal, null: true, foreign_key: true
  end
end
