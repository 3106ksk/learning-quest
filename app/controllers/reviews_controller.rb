class ReviewsController < ApplicationController
  before_action :set_goal
  before_action :set_weekly_reflection
  before_action :ensure_active

  def update
    if @weekly_reflection.update(review_params.merge(reflected_at: Time.current))
      redirect_to goal_weekly_reflection_path(@goal, @weekly_reflection), status: :see_other
    else
      @weekly_study = WeeklyStudyAggregator.call(
        goal: @goal,
        week_start_on: @weekly_reflection.week_start_on,
        learning_skill: @weekly_reflection.learning_skill
      )
      render "weekly_reflections/show", status: :unprocessable_content
    end
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:goal_id])
  end

  def set_weekly_reflection
    @weekly_reflection = @goal.weekly_reflections.find(params[:weekly_reflection_id])
  end

  def ensure_active
    return if @goal.active?

    redirect_to goal_weekly_reflection_path(@goal, @weekly_reflection), danger: t(".danger"), status: :see_other
  end

  def review_params
    params.expect(weekly_reflection: [ :feeling, :comment ])
  end
end
