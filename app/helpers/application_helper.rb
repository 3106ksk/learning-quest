module ApplicationHelper
  def nav_current(target_controller)
    "page" if controller_name == target_controller
  end
end
