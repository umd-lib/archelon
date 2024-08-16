class ChangeMimeTypeColumnName < ActiveRecord::Migration[4.2]
  def change
    rename_column "download_urls", "mimetype", "mime_type"
  end
end
