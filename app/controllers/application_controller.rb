class ApplicationController < ActionController::Base
  include Authentication

  skip_before_action :require_authentication, if: :devise_controller?
  
  add_flash_types :success, :danger

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

    def after_sign_in_path_for(resource)
      new_study_record_path
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [ :account_name ])
    end
end
