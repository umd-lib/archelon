class AddIndexToCasUsersCasDirectoryId < ActiveRecord::Migration[4.2]
  def change
    add_index :cas_users, :cas_directory_id, unique: true
  end
end
