class Goal < ApplicationRecord
  belongs_to :user
  has_many :study_records, dependent: :destroy

  enum :status, {
    active: "active",
    completed: "completed"
  }, validate: true

  validates :name, presence: true, length: { maximum: 100 }
  validates :user_id, uniqueness: {
    conditions: -> { where(status: "active") }
  }, if: :active?

  def complete!
    raise "進行中の目標だけ完了できます" unless active?

    update!(status: :completed, completed_at: Time.current)
  end
end
