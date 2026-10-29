class WeeklyReflectionsController < ApplicationController
  before_action :set_goal
  before_action :ensure_active, only: [ :new, :create ]
  before_action :set_skill_settings, only: [ :new, :create ]

  def new
    week_start_on = WeeklyReflection.current_week_start_on
    @weekly_reflection = @goal.weekly_reflections.find_by(week_start_on: week_start_on)

    if @weekly_reflection
      redirect_to goal_weekly_reflection_path(@goal, @weekly_reflection)
    else
      @weekly_reflection = @goal.weekly_reflections.build(week_start_on: week_start_on)
    end
  end

  def show
    @weekly_reflection = @goal.weekly_reflections.find(params[:id])
  end

  def create
    @weekly_reflection = @goal.weekly_reflections.build(weekly_reflection_params)
    @weekly_reflection.week_start_on = WeeklyReflection.current_week_start_on

    if @weekly_reflection.save
      redirect_to goal_weekly_reflection_path(@goal, @weekly_reflection), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    @weekly_reflection = @goal.weekly_reflections.find_by!(
      week_start_on: @weekly_reflection.week_start_on
    )

    redirect_to goal_weekly_reflection_path(@goal, @weekly_reflection), status: :see_other
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:goal_id])
  end

  def ensure_active
    return if @goal.active?

    redirect_to goal_path(@goal), danger: t(".danger"), status: :see_other
  end

  def set_skill_settings
    @skill_settings = @goal.goal_skill_settings.includes(:learning_skill).order(created_at: :desc)
  end

  def weekly_reflection_params
    params.expect(weekly_reflection: [ :learning_skill_id, :expectation, :expectation_note ])
  end
end
