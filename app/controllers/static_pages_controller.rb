class StaticPagesController < ApplicationController
  skip_before_action :require_authentication, only: :home
  skip_before_action :authenticate_user!, only: :home
  before_action :redirect_authenticated_users, only: :home

  def home
  end

  private

    def redirect_authenticated_users
      redirect_to new_study_record_path if user_signed_in?
    end
end
