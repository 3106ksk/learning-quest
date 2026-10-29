module WeeklyReflectionsHelper
  def weekly_reflection_period(week_start_on)
    "#{l(week_start_on, format: :record)}〜#{l(week_start_on + 6.days, format: :record)}"
  end
end
