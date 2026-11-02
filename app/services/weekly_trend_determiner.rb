class WeeklyTrendDeterminer
  def self.call(weekly_study:)
    new(weekly_study: weekly_study).call
  end

  def initialize(weekly_study:)
    @weekly_study = weekly_study
  end

  def call
    previous_study_count = weekly_study[:previous][:study_count]
    current_study_count = weekly_study[:current][:study_count]
    previous_study_days = weekly_study[:previous][:study_days]
    current_study_days = weekly_study[:current][:study_days]
    previous_week_exists = weekly_study[:previous_week_exists]
    week_finished = weekly_study[:week_finished]


    {
      study_count: judge_count(:study_count, previous_study_count, current_study_count, previous_week_exists, week_finished),
      study_days: judge_count(:study_days, previous_study_days, current_study_days, previous_week_exists, week_finished)
    }
  end

  private

  attr_reader :weekly_study

  def judge_count(kind, previous, current, previous_week_exists, week_finished)
    if !previous_week_exists
      { kind: kind, status: :no_previous }
    elsif !week_finished
      { kind: kind, status: :in_progress, current: current }
    elsif previous_week_exists && week_finished && ((previous - current).abs >= 1)
      { kind: kind, status: :changed, previous: previous, current: current }
    else
      { kind: kind, status: :unchanged, previous: previous, current: current }
    end
  end
end
