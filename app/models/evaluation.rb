class Evaluation < ApplicationRecord
  belongs_to :study_record
  belongs_to :focus_option
  belongs_to :challenge_option

  validates :study_record_id, uniqueness: true
  validates :focus_point, presence: true, inclusion: { in: 1..3 }
  validates :challenge_point, presence: true, inclusion: { in: 1..3 }

  before_validation :copy_option_points, on: :create

  private

  def copy_option_points
    self.focus_point = focus_option&.point
    self.challenge_point = challenge_option&.point
  end
end
