class AddMimeTypesToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :mime_types, :string
  end
end
