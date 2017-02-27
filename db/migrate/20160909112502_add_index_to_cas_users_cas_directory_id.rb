class AddIndexToCasUsersCasDirectoryId < ActiveRecord::Migration
  def change
    add_index :cas_users, :cas_directory_id, unique: true
  end
end
