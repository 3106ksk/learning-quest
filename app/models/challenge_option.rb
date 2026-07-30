class ChallengeOption < ApplicationRecord
  validates :result_code, presence: true, uniqueness: true
  validates :label, presence: true
  validates :point, presence: true, inclusion: { in: 1..3 }
  validates :position, presence: true
end
