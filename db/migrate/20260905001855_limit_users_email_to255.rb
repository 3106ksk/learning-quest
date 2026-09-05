class LimitUsersEmailTo255 < ActiveRecord::Migration[8.1]
  def up
    change_column :users, :email, :string,
                  limit: 255,
                  null: false,
                  default: ""
  end

  def down
    change_column :users, :email, :string,
                  limit: nil,
                  null: false,
                  default: ""
  end
end
