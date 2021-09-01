class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.date :date_of_birth
      t.text :bio
      t.boolean :has_muggle_relatives

      t.timestamps
    end
  end
end
