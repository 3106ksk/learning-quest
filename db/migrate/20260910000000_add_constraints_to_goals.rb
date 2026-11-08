class AddConstraintsToGoals < ActiveRecord::Migration[8.1]
  INDEX_NAME = "index_goals_on_active_user_id"

  def up
    change_column_null :goals, :name, false
    change_column_default :goals, :status, from: nil, to: "active"
    change_column_null :goals, :status, false

    add_index :goals, :user_id,
              unique: true,
              where: "status = 'active'",
              name: INDEX_NAME
  end

  def down
    remove_index :goals, name: INDEX_NAME

    change_column_null :goals, :status, true
    change_column_default :goals, :status, from: "active", to: nil
    change_column_null :goals, :name, true
  end
end
