class RemoveDownloadUrlFromExportJobs < ActiveRecord::Migration[5.2]
  def change
    remove_column :export_jobs, :download_url, :string
  end
end
