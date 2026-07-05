class SignUpsController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  def show
    @user = User.new
  end
end
