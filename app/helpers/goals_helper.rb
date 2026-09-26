module GoalsHelper
  def goal_tile_slots(goal_count)
    tiles_with_next_goal = goal_count + 1
    total_tiles = [ 12, ((tiles_with_next_goal + 11) / 12) * 12 ].max

    total_tiles - tiles_with_next_goal
  end
end
