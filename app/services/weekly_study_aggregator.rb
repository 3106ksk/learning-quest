class WeeklyStudyAggregator
  def self.call(goal:, week_start_on:, learning_skill:)
    new(
      goal: goal,
      week_start_on: week_start_on,
      learning_skill: learning_skill
    ).call
  end

  def initialize(goal:, week_start_on:, learning_skill:)
    @goal = goal
    @week_start_on = week_start_on
    @learning_skill = learning_skill
  end

  def call
    current = week_start_on.in_time_zone.all_week
    previous = week_start_on.prev_week.in_time_zone.all_week
    focus_options = FocusOption.display_order.to_a
    challenge_options = ChallengeOption.display_order.to_a

    {
      current: aggregate_week(current, focus_options, challenge_options),
      previous: aggregate_week(previous, focus_options, challenge_options),
      previous_week_exists: goal.created_at < week_start_on.in_time_zone,
      week_finished: Time.current >= week_start_on.next_week.in_time_zone
    }
  end

  private

  attr_reader :goal, :week_start_on, :learning_skill

  def aggregate_week(week_range, focus_options, challenge_options)
    records = records_in_week(week_range).to_a
    selected_records = records.find_all { |r| r.learning_skill_id == learning_skill.id }
    focus_counts = selected_records.map { |r| r.evaluation.focus_option_id }.tally
    challenge_counts = selected_records.map { |r| r.evaluation.challenge_option_id }.tally

    {
      study_count: records.size,
      study_days: records.uniq { |r| r.started_at.to_date }.size,
      selected_count: selected_records.size,
      focus: focus_options.to_h { |option| [ option, focus_counts.fetch(option.id, 0) ] },
      challenge: challenge_options.to_h { |option| [ option, challenge_counts.fetch(option.id, 0) ] }
    }
  end

  def records_in_week(week_range)
    goal.study_records.evaluated.where(started_at: week_range).includes(:evaluation)
  end
end
