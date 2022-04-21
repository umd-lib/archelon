class RemovePlastronStatusFromExportJobs < ActiveRecord::Migration[5.2]
  def change
    remove_column :export_jobs, :plastron_status
  end
end
