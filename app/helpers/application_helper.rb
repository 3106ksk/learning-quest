module ApplicationHelper
  def nav_current(*target_controllers)
    "page" if target_controllers.include?(controller_name)
  end
end
