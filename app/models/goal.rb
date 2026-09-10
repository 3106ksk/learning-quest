class Goal < ApplicationRecord
  belongs_to :user
  has_many :study_records, dependent: :destroy

  enum :status, {
    active: "active",
    completed: "completed"
  }, validate: true

  validates :name, presence: true
  validates :user_id, uniqueness: {
    conditions: -> { where(status: "active") }
  }, if: :active?
end
