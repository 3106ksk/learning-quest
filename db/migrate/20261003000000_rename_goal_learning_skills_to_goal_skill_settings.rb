class RenameGoalLearningSkillsToGoalSkillSettings < ActiveRecord::Migration[8.1]
  def change
    rename_table :goal_learning_skills, :goal_skill_settings
  end
end
