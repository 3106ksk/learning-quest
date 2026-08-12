class CreateEvaluations < ActiveRecord::Migration[8.1]
  def change
    create_table :evaluations do |t|
      t.references :study_record, null: false, foreign_key: true, index: { unique: true }
      t.references :focus_option, null: false, foreign_key: true
      t.references :challenge_option, null: false, foreign_key: true
      t.integer :focus_point, null: false
      t.integer :challenge_point, null: false

      t.check_constraint "focus_point BETWEEN 1 AND 3", name: "evaluations_focus_point_range"
      t.check_constraint "challenge_point BETWEEN 1 AND 3", name: "evaluations_challenge_point_range"

      t.timestamps
    end
  end
end
