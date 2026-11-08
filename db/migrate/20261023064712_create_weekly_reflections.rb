class CreateWeeklyReflections < ActiveRecord::Migration[8.1]
  def change
    create_table :weekly_reflections do |t|
      t.references :goal, null: false, foreign_key: true
      t.references :learning_skill, null: false, foreign_key: true
      t.date :week_start_on, null: false
      t.string :expectation, null: false
      t.string :expectation_note, limit: 200
      t.string :feeling
      t.string :comment, limit: 200
      t.datetime :reflected_at

      t.timestamps
    end

    add_index :weekly_reflections, [ :goal_id, :week_start_on ], unique: true

    add_check_constraint :weekly_reflections,
                         "expectation IN ('easy_start', 'focus', 'challenge', 'undecided')",
                         name: "weekly_reflections_expectation_allowed_values"

    add_check_constraint :weekly_reflections,
                         "feeling IN ('felt', 'not_much', 'unsure')",
                         name: "weekly_reflections_feeling_allowed_values"

    add_check_constraint :weekly_reflections,
                         "(reflected_at IS NULL) = (feeling IS NULL)",
                         name: "weekly_reflections_feeling_and_reflected_at_together"
  end
end
