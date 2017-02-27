class CreateCasUsers < ActiveRecord::Migration
  def change
    create_table :cas_users do |t|
      t.string :cas_directory_id
      t.string :name

      t.timestamps null: false
    end
  end
end
