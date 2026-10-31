class WeeklyStudyAggregator
  def self.call(goal:, week_start_on:, learning_skill:)
    new(
      goal: goal,
      week_start_on: week_start_on,
      learning_skill: learning_skill
    )
  end

  def initialize(goal:, week_start_on:, learning_skill:)
    @goal = goal
    @week_start_on = week_start_on
    @learning_skill = learning_skill
  end

  private

  attr_reader :goal, :week_start_on, :learning_skill
end
