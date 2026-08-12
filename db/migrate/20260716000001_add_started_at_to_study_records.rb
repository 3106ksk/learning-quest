class AddStartedAtToStudyRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :study_records, :started_at, :datetime, null: false
  end
end
