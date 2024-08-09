class RemoveAdminFromCasUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :cas_users, :admin, :boolean
  end
end
