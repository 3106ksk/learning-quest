class GoalsController < ApplicationController
  before_action :set_goal, only: [ :show, :edit, :update, :complete ]
  before_action :ensure_active, only: [ :edit, :update, :complete ]

  def index
    @goals = current_user.goals.order(completed_at: :desc)
  end

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

  def complete
    @goal.complete!
    redirect_to @goal, status: :see_other
  end

  private

  def set_goal
    @goal = current_user.goals.find(params[:id])
  end

  def ensure_active
    return if @goal.active?

    redirect_to @goal, danger: t(".danger"), status: :see_other
  end

  def goal_params
    params.expect(goal: [ :name ])
  end
end
