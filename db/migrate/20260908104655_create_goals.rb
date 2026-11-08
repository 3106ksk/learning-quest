class CreateGoals < ActiveRecord::Migration[8.1]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :status
      t.datetime :completed_at

      t.timestamps
    end
  end
end
