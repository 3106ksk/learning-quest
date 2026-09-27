class CreateLearningSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :learning_skills do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, limit: 100, null: false

      t.timestamps
    end

    add_index :learning_skills, [ :user_id, :name ], unique: true
  end
end
