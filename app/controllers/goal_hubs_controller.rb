class GoalHubsController < ApplicationController
  def show
    @current_goal = current_user.goals.active.take
  end
end
