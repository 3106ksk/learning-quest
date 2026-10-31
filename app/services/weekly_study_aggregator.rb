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
    current = week_start_on.all_week
    previous = week_start_on.prev_week.all_week

    {
      current: aggregate_week(current),
      previous: aggregate_week(previous)
    }
  end

  private

  attr_reader :goal, :week_start_on, :learning_skill

  def aggregate_week(week_range)
    records = records_in_week(week_range).to_a

    {
      study_count: records.size
    }
  end

  def records_in_week(week_range)
    goal.study_records.evaluated.where(started_at: week_range)
  end
end
