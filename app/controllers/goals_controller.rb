class GoalsController < ApplicationController
  def new
    @goal = current_user.goals.build
  end
end
