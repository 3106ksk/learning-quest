module WeeklyReflectionsHelper
  def weekly_reflection_period(week_start_on)
    "#{l(week_start_on, format: :record)}〜#{l(week_start_on + 6.days, format: :record)}"
  end

  def weekly_reflection_period_with_weekday(week_start_on)
    "#{l(week_start_on, format: :record_weekday)}〜#{l(week_start_on + 6.days, format: :record_weekday)}"
  end

  # 期待する変化ごとに、週の記録のどこに注目の枠を付けるか
  def weekly_study_highlight(expectation)
    {
      totals: expectation.to_s == "easy_start",
      focus: expectation.to_s == "focus",
      challenge: expectation.to_s == "challenge"
    }
  end
end
