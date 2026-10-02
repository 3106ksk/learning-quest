class LearningSkillsController < ApplicationController
  def index
    set_learning_skills
  end

  def new
    @learning_skill = current_user.learning_skills.build
  end

  def create
    @learning_skill = current_user.learning_skills.build(learning_skill_params)

    if @learning_skill.save
      redirect_to new_learning_skill_path, success: t(".success"), status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_learning_skill_path, danger: t(".danger"), status: :see_other
  end

  private

  def set_learning_skills
    @learning_skills = current_user.learning_skills.order(created_at: :desc)
  end

  def learning_skill_params
    params.expect(learning_skill: [ :name ])
  end
end
