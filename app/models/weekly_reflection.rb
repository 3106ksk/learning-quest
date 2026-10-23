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
end
