class AddHouseToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :house, :string
  end
end
