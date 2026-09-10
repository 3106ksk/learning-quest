class Goal < ApplicationRecord
  belongs_to :user

  enum :status, {
    active: "active",
    completed: "completed"
  }, validate: true

  validates :name, presence: true
  validates :user_id, uniqueness: {
    conditions: -> { where(status: "active") }
  }, if: :active?
end
