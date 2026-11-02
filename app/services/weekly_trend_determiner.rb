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
    previous_focus = weekly_study[:previous][:focus].map { |f, n| [ f.label, n ] }
    current_focus = weekly_study[:current][:focus].map { |f, n| [ f.label, n ] }
    previous_challenge = weekly_study[:previous][:challenge].map { |c, n| [ c.label, n ] }
    current_challenge = weekly_study[:current][:challenge].map { |c, n| [ c.label, n ] }

    {
      study_count: judge_count(:study_count, previous_study_count, current_study_count, previous_week_exists, week_finished),
      study_days: judge_count(:study_days, previous_study_days, current_study_days, previous_week_exists, week_finished),
      focus: judge_breakdown(previous_focus, current_focus, previous_selected_count, current_selected_count, previous_week_exists),
      challenge: judge_breakdown(previous_challenge, current_challenge, previous_selected_count, current_selected_count, previous_week_exists)
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

  def judge_breakdown(previous, current, previous_selected_count, current_selected_count, previous_week_exists)
    if !previous_week_exists
      { status: :no_previous }
    elsif current_selected_count == 0
      { status: :no_selection }
    elsif previous_selected_count < MINIMUM_SELECTED_COUNT || current_selected_count < MINIMUM_SELECTED_COUNT
      { status: :too_few }
    else
      largest = previous.zip(current).max_by do |(_, previous_count), (_, current_count)|
        ratio_difference(previous_count, previous_selected_count, current_count, current_selected_count)
      end
      (label, previous_count), (_, current_count) = largest

      if ratio_difference(previous_count, previous_selected_count, current_count, current_selected_count) >= CHANGE_THRESHOLD
        { status: :changed, previous: [ label, previous_count ], current: [ label, current_count ] }
      else
        { status: :unchanged, previous: [ label, previous_count ], current: [ label, current_count ] }
      end
    end
  end

  def ratio_difference(previous_count, previous_total, current_count, current_total)
    ((Rational(previous_count, previous_total) - Rational(current_count, current_total)) * 100).abs
  end
end
