class GoalSkillSettingsController < ApplicationController
  before_action :set_goal
  before_action :ensure_active

  def index
    @learning_skills = current_user.learning_skills.order(created_at: :desc)
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:goal_id])
  end

  def ensure_active
    return if @goal.active?

    redirect_to goal_path(@goal), danger: t(".danger"), status: :see_other
  end
end
