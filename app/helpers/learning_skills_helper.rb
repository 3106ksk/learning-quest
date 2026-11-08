module LearningSkillsHelper
  def learning_skill_tile_slots(skill_count)
    total_tiles = [ 12, ((skill_count + 11) / 12) * 12 ].max

    total_tiles - skill_count
  end
end
