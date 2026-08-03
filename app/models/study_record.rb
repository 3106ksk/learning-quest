class StudyRecord < ApplicationRecord
  ALLOWED_PLANNED_MINUTES = [ 5, 15, 25, 50 ].freeze
  ACTIVE_STATUSES = %w[running paused awaiting_evaluation].freeze

  belongs_to :user
  has_one :evaluation, dependent: :destroy

  enum :status, {
    running: "running",
    paused: "paused",
    awaiting_evaluation: "awaiting_evaluation",
    evaluated: "evaluated"
  }, validate: true

  enum :rank, {
    a: "a",
    b: "b",
    c: "c"
  }, prefix: true, validate: { allow_nil: true }

  before_create :set_expires_at

  scope :active, -> { where(status: ACTIVE_STATUSES) }

  validates :planned_minutes, presence: true, inclusion: { in: ALLOWED_PLANNED_MINUTES }
  validates :activity, presence: true, length: { maximum: 100 }
  validates :started_at, presence: true
  validates :rank, presence: true, if: :evaluated?
  validates :user_id, uniqueness: {
    conditions: -> { where(status: ACTIVE_STATUSES) }
  }

  def start_pause!
    update!(
      status: :paused,
      current_pause_started_at: Time.current,
      pause_count: pause_count + 1
    )
  end

  def start_resume!
    raise "一時停止中の記録だけ再開できます" unless paused?

    now = Time.current
    pause_duration = calculate_pause_duration(now)

    update!(
      status: :running,
      expires_at: expires_at + pause_duration,
      paused_seconds: paused_seconds + pause_duration.to_i,
      current_pause_started_at: nil
    )
  end

  def complete!
    raise "実行中または一時停止中の記録だけ完了できます" unless running? || paused?

    now = Time.current
    pause_duration = paused? ? calculate_pause_duration(now) : 0
    new_paused_seconds = paused_seconds + pause_duration.to_i
    actual_seconds = (now - started_at).to_i - new_paused_seconds

    update!(
      status: :awaiting_evaluation,
      ended_at: now,
      paused_seconds: new_paused_seconds,
      actual_seconds: actual_seconds,
      current_pause_started_at: nil
    )
  end

  def mark_as_evaluated!
    raise "評価待ちの記録だけ評価完了にできます" unless awaiting_evaluation?

    update!(status: :evaluated)
  end

  def frozen_remaining_seconds
    (expires_at - current_pause_started_at).to_i
  end

  # STUDY-03の実績時間表示用。四捨五入(切り捨てだと59秒が「0分」と表示され、
  # 学習していないように見えるため、実態に近い側へ丸める)。
  def actual_minutes
    return nil if actual_seconds.nil?

    (actual_seconds / 60.0).round
  end

  private

  def calculate_pause_duration(now)
    raise "一時停止開始時刻がありません" if current_pause_started_at.nil?

    now - current_pause_started_at
  end

  def set_expires_at
    self.expires_at = started_at + planned_minutes.minutes
  end
end
