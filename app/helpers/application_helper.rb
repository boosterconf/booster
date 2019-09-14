# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def admin?
    current_user and current_user.is_admin
  end

  def self.early_bird_end_date
    to_date AppConfig.early_bird_ends
  end

  def self.to_date(a_string)
    DateTime.strptime(a_string, "%Y-%m-%d %H:%M:%S").to_time
  end

  def cp(path)
    "current" if current_page?(path)
  end
end
