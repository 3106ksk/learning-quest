class WeeklyReflection < ApplicationRecord
  belongs_to :goal
  belongs_to :learning_skill

  normalizes :expectation_note, :comment, with: ->(value) { value.strip.presence }

  validates :week_start_on, presence: true, uniqueness: { scope: :goal_id }
  validates :expectation_note, :comment, length: { maximum: 200 }
end
