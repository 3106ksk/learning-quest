class CreateFocusOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :focus_options do |t|
      t.string :result_code, null: false
      t.string :label, null: false
      t.string :description
      t.integer :point, null: false
      t.integer :position, null: false

      t.check_constraint "point BETWEEN 1 AND 3", name: "focus_options_point_range"

      t.timestamps
    end

    add_index :focus_options, :result_code, unique: true
  end
end
