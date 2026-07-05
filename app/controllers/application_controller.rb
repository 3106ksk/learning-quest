class ApplicationController < ActionController::Base
  include Authentication
  add_flash_types :success, :danger

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
