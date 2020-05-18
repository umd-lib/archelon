class AddPlastronStatusProgressFieldsToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :plastron_status, :string
    add_column :export_jobs, :progress, :integer
  end
end
