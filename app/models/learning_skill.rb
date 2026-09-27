class LearningSkill < ApplicationRecord
  belongs_to :user

  normalizes :name, with: ->(name) { name.strip }

  validates :name,
            presence: true,
            length: { maximum: 100 },
            uniqueness: { scope: :user_id }
end
