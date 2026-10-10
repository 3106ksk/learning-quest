class GoalSkillSetting < ApplicationRecord
  MAX_PER_GOAL = 3

  belongs_to :goal
  belongs_to :learning_skill

  validates :learning_skill_id, uniqueness: { scope: :goal_id }
  validate :skills_per_goal_limit, on: :create

  private

  # build直後のsizeは未保存の行も数えるため、DBに保存済みの件数をcountで数える
  def skills_per_goal_limit
    return if goal.nil?

    if goal.goal_skill_settings.count >= MAX_PER_GOAL
      errors.add(:base, :too_many_skills, count: MAX_PER_GOAL)
    end
  end
end
