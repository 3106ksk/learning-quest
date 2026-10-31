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
      current: current,
      previous: previous
    }
  end

  private

  attr_reader :goal, :week_start_on, :learning_skill
end
