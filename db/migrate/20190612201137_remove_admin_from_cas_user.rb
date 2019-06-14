class RemoveAdminFromCasUser < ActiveRecord::Migration
  def change
    remove_column :cas_users, :admin, :boolean
  end
end
