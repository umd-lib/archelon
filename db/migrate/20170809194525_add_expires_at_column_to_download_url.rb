class AddExpiresAtColumnToDownloadUrl < ActiveRecord::Migration[4.2]
  def change
    add_column :download_urls, :expires_at, :datetime
  end
end
