class CreateGoalLearningSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :goal_learning_skills do |t|
      t.references :goal, null: false, foreign_key: true
      t.references :learning_skill, null: false, foreign_key: true

      t.timestamps
    end

    add_index :goal_learning_skills, [ :goal_id, :learning_skill_id ], unique: true
  end
end
