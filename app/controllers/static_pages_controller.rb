class StaticPagesController < ApplicationController
  allow_unauthenticated_access
  before_action :redirect_authenticated_users

  def home
  end

  private

    def redirect_authenticated_users
      redirect_to new_study_record_path if authenticated?
    end
end
