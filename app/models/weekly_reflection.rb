class WeeklyReflection < ApplicationRecord
  belongs_to :goal
  belongs_to :learning_skill

  enum :expectation, {
    easy_start: "easy_start",
    focus: "focus",
    challenge: "challenge",
    undecided: "undecided"
  }, prefix: true, validate: true

  enum :feeling, {
    felt: "felt",
    not_much: "not_much",
    unsure: "unsure"
  }, prefix: true, validate: { allow_nil: true }

  normalizes :expectation_note, :comment, with: ->(value) { value.strip.presence }

  validates :week_start_on, presence: true, uniqueness: { scope: :goal_id }
  validates :expectation_note, :comment, length: { maximum: 200 }
  validate :learning_skill_in_goal_settings, on: :create

  private

  def learning_skill_in_goal_settings
    return if learning_skill_id.nil?
    return if goal.nil?

    unless goal.goal_skill_settings.exists?(learning_skill_id: learning_skill_id)
      errors.add(:learning_skill_id, :not_in_goal_settings)
    end
  end
end
