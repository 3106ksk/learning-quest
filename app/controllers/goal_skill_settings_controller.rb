class GoalSkillSettingsController < ApplicationController
  before_action :set_goal
  before_action :ensure_active

  def index
    @learning_skills = current_user.learning_skills.order(created_at: :desc)
  end

  def create
    learning_skill = current_user.learning_skills.find(params[:learning_skill])

    skill_setting = @goal.goal_skill_settings.build(learning_skill_id: learning_skill.id)
    skill_setting.save

    redirect_to goal_skill_settings_path(@goal), status: :see_other
  rescue ActiveRecord::RecordNotUnique
    redirect_to goal_skill_settings_path(@goal), status: :see_other
  end

  def destroy
    skill_setting = @goal.goal_skill_settings.find_by(id: params[:id])
    skill_setting&.destroy

    redirect_to goal_skill_settings_path(@goal), status: :see_other
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
