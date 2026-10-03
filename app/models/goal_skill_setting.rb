class GoalSkillSetting < ApplicationRecord
  belongs_to :goal
  belongs_to :learning_skill

  validates :learning_skill_id, uniqueness: { scope: :goal_id }
end
