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
  validates :feeling, presence: true, if: -> { reflected_at.present? }
  validate :learning_skill_in_goal_settings, on: :create

  def self.current_week_start_on
    Date.current.beginning_of_week
  end

  def skill_total
    week_start_ons = goal.weekly_reflections.where(learning_skill_id: learning_skill_id, week_start_on: ..week_start_on).pluck(:week_start_on)
    count = goal.study_records.evaluated.where(learning_skill_id: learning_skill_id, started_at: week_start_ons.map { |date| date.in_time_zone.all_week }).count

    { weeks: week_start_ons.size, count: count }
  end

  private

  def learning_skill_in_goal_settings
    return if learning_skill_id.nil?
    return if goal.nil?

    unless goal.goal_skill_settings.exists?(learning_skill_id: learning_skill_id)
      errors.add(:learning_skill_id, :not_in_goal_settings)
    end
  end
end
