class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.timestamps
    end

    create_table :cas_users_groups, id: false do |t|
      t.belongs_to :cas_user
      t.belongs_to :group
    end
  end
end
