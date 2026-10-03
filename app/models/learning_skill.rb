class LearningSkill < ApplicationRecord
  belongs_to :user
  has_many :study_records, dependent: :restrict_with_error
  has_many :goal_skill_settings, dependent: :destroy

  normalizes :name, with: ->(name) { name.strip }

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :user_id }
end
