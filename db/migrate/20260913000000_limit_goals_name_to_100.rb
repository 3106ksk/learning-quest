class LimitGoalsNameTo100 < ActiveRecord::Migration[8.1]
  def up
    change_column :goals, :name, :string, limit: 100, null: false
  end

  def down
    change_column :goals, :name, :string, limit: nil, null: false
  end
end
