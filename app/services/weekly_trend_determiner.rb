class WeeklyTrendDeterminer
  CHANGE_THRESHOLD = 35
  MINIMUM_SELECTED_COUNT = 3

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
    previous_selected_count = weekly_study[:previous][:selected_count]
    current_selected_count = weekly_study[:current][:selected_count]

    {
      study_count: judge_count(:study_count, previous_study_count, current_study_count, previous_week_exists, week_finished),
      study_days: judge_count(:study_days, previous_study_days, current_study_days, previous_week_exists, week_finished),
      focus: judge_breakdown(:focus, weekly_study[:previous][:focus], weekly_study[:current][:focus], previous_selected_count, current_selected_count, previous_week_exists),
      challenge: judge_breakdown(:challenge, weekly_study[:previous][:challenge], weekly_study[:current][:challenge], previous_selected_count, current_selected_count, previous_week_exists)
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

  def judge_breakdown(kind, previous, current, previous_total, current_total, previous_week_exists)
    if !previous_week_exists
      { kind: kind, status: :no_previous }
    elsif current_total == 0
      { kind: kind, status: :no_selection }
    elsif previous_total < MINIMUM_SELECTED_COUNT || current_total < MINIMUM_SELECTED_COUNT
      { kind: kind, status: :too_few, previous_total: previous_total, current_total: current_total }
    else
      option = current.keys.max_by { |o| ratio_difference(previous[o], previous_total, current[o], current_total) }

      if ratio_difference(previous[option], previous_total, current[option], current_total) >= CHANGE_THRESHOLD
        { kind: kind, status: :changed, option: option,
          previous_total: previous_total, previous_count: previous[option],
          current_total: current_total, current_count: current[option] }
      else
        { kind: kind, status: :unchanged, previous_total: previous_total, current_total: current_total }
      end
    end
  end

  def ratio_difference(previous_count, previous_total, current_count, current_total)
    ((Rational(previous_count, previous_total) - Rational(current_count, current_total)) * 100).abs
  end
end
