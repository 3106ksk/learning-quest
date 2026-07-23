class RemoveAwaitingExtendOrFinishFromStudyRecordsIndex < ActiveRecord::Migration[8.1]
  INDEX_NAME = "index_study_records_on_active_user_id"

  def up
    remove_index :study_records, name: INDEX_NAME

    add_index :study_records, :user_id,
              unique: true,
              where: "status IN ('running', 'paused', 'awaiting_evaluation')",
              name: INDEX_NAME
  end

  def down
    remove_index :study_records, name: INDEX_NAME

    add_index :study_records, :user_id,
              unique: true,
              where: "status IN ('running', 'paused', 'awaiting_extend_or_finish', 'awaiting_evaluation')",
              name: INDEX_NAME
  end
end
