class AddAdminColumnToCasUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :cas_users, :admin, :boolean, :default => false
  end
end
