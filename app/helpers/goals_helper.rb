module GoalsHelper
  # 目標一覧の日付。進行中は設定した日、完了は完了した日を出す
  def goal_list_date(goal)
    if goal.completed?
      t("goals.index.completed_on", date: l(goal.completed_at.to_date, format: :record))
    else
      t("goals.index.since", date: l(goal.created_at.to_date, format: :record))
    end
  end

  def goal_tile_slots(goal_count)
    tiles_with_next_goal = goal_count + 1
    total_tiles = [ 12, ((tiles_with_next_goal + 11) / 12) * 12 ].max

    total_tiles - tiles_with_next_goal
  end
end
