class AddAdminColumnToCasUsers < ActiveRecord::Migration
  def change
    add_column :cas_users, :admin, :boolean, :default => false
  end
end
