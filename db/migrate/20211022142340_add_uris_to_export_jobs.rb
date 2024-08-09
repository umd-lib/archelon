class AddUrisToExportJobs < ActiveRecord::Migration[5.2]
  def change
    add_column :export_jobs, :uris, :string
  end
end
