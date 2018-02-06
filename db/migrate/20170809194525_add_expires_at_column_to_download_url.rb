class AddExpiresAtColumnToDownloadUrl < ActiveRecord::Migration
  def change
    add_column :download_urls, :expires_at, :datetime
  end
end
