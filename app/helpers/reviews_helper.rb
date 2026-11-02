module ReviewsHelper
  COUNT_KINDS = [ :study_count, :study_days ].freeze

  def review_trend_items(trends, weekly_reflection)
    if trends.map { |trend| trend[:status] } == [ :in_progress, :in_progress ]
      [ { label: t("reviews.show.trend_labels.study_count_and_days"), sentence: review_in_progress_sentence(trends, weekly_reflection) } ]
    else
      trends.map { |trend| { label: review_trend_label(trend), sentence: review_trend_sentence(trend, weekly_reflection) } }
    end
  end

  def review_continuation_sentence(weekly_reflection, selected_count:, skill_total:)
    skill = weekly_reflection.learning_skill.name
    sentence =
      if selected_count.positive?
        t("reviews.show.continuation.selected", skill: skill, count: selected_count)
      else
        t("reviews.show.continuation.not_selected", skill: skill)
      end
    return sentence if skill_total[:weeks] < 2

    sentence + t("reviews.show.continuation.total", weeks: skill_total[:weeks], count: skill_total[:count])
  end

  private

  def review_trend_label(trend)
    t("reviews.show.trend_labels.#{trend[:kind]}")
  end

  def review_trend_sentence(trend, weekly_reflection)
    if trend[:status] == :no_previous
      t("reviews.show.trends.no_previous")
    elsif COUNT_KINDS.include?(trend[:kind])
      t("reviews.show.trends.#{trend[:kind]}.#{trend[:status]}",
        previous: trend[:previous],
        current: trend[:current],
        previous_period: weekly_reflection_period(weekly_reflection.week_start_on.prev_week),
        current_period: weekly_reflection_period(weekly_reflection.week_start_on))
    else
      t("reviews.show.trends.breakdown.#{trend[:status]}",
        skill: weekly_reflection.learning_skill.name,
        kind: review_trend_label(trend),
        option: trend[:option]&.label,
        previous_total: trend[:previous_total],
        previous_count: trend[:previous_count],
        current_total: trend[:current_total],
        current_count: trend[:current_count])
    end
  end

  def review_in_progress_sentence(trends, weekly_reflection)
    current = trends.to_h { |trend| [ trend[:kind], trend[:current] ] }
    period = "#{l(weekly_reflection.week_start_on, format: :record)}〜#{l(Date.current, format: :record)}"

    t("reviews.show.trends.in_progress", period: period, study_count: current[:study_count], study_days: current[:study_days])
  end
end
