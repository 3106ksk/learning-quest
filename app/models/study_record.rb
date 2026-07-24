class StudyRecord < ApplicationRecord
  ALLOWED_PLANNED_MINUTES = [ 5, 15, 25, 50 ].freeze

  belongs_to :user

  enum :status, {
    running: "running",
    paused: "paused",
    awaiting_evaluation: "awaiting_evaluation"
  }, validate: true

  before_create :set_expires_at

  validates :planned_minutes, presence: true, inclusion: { in: ALLOWED_PLANNED_MINUTES }
  validates :activity, presence: true, length: { maximum: 100 }
  validates :started_at, presence: true
  validates :user_id, uniqueness: {
    conditions: -> { where(status: %w[running paused awaiting_evaluation]) }
  }

  def start_pause!
    update!(
      status: :paused,
      current_pause_started_at: Time.current,
      pause_count: pause_count + 1
    )
  end

  def start_resume!
    pause_duration = Time.current - current_pause_started_at

    update!(
      status: :running,
      expires_at: expires_at + pause_duration,
      paused_seconds: paused_seconds + pause_duration.to_i,
      current_pause_started_at: nil
    )
  end

  private

  def set_expires_at
    self.expires_at = started_at + planned_minutes.minutes
  end
end
