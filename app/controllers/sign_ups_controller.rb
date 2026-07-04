class SignUpsController < ApplicationController
  def show
    @user = User.new
  end
end
