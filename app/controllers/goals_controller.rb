class GoalsController < ApplicationController
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

  private

  def goal_params
    params.expect(goal: [ :name ])
  end
end
