  class StudyRecord < ApplicationRecord
    belongs_to :user

    enum :status, {
      running: "running",
      paused: "paused",
      awaiting_extend_or_finish: "awaiting_extend_or_finish",
      awaiting_evaluation: "awaiting_evaluation"
    }, validate: true

    validates :planned_minutes, presence: true, inclusion: { in: [5, 15, 25, 50] }
    validates :activity, length: { maximum: 100 }, allow_blank: true
    validates :started_at, presence: true
    validates :user_id, uniqueness: {
      conditions: -> { where(status: %w[running paused awaiting_extend_or_finish awaiting_evaluation]) }
    }
  end
