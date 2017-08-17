class ChangeMimeTypeColumnName < ActiveRecord::Migration
  def change
    rename_column "download_urls", "mimetype", "mime_type"
  end
end
