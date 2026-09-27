class AddLearningSkillToStudyRecords < ActiveRecord::Migration[8.1]
  def change
    add_reference :study_records, :learning_skill, null: true, foreign_key: true
  end
end
