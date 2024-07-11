class AddDownloadUrlToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :download_url, :string
  end
end
