class GoalsController < ApplicationController
  before_action :set_goal, only: [ :show, :edit, :update ]

  def new
    @goal = current_user.goals.build
  end

  def create
    @goal = current_user.goals.build(goal_params)

    if @goal.save
      redirect_to new_study_record_path, success: t(".success"), status: :see_other
    else
      flash.now[:danger] = t(".danger")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @goal.update(goal_params)
      redirect_to goal_path(@goal), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def goal_params
    params.expect(goal: [ :name ])
  end
end
